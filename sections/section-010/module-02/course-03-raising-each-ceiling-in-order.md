# Part 3 — Raising each ceiling, in order

> Prerequisite: [Part 2 — The three independent ceilings](./course-02-the-three-independent-ceilings.md). Next: [Section 010 quiz](../quiz.md).

Each ceiling has the section's standard shape: a live change that applies now, and a config file that a boot-time or login-time step replays. This part is all three, live and persistent, plus the fixed order to check them in so an incident does not resurface.

## Ceiling 1 — `kernel.pid_max`

Live, then persistent — the Chapter 1 sysctl pattern, unchanged:

```bash
# shell: host, root
sudo sysctl -w kernel.pid_max=4194304

echo 'kernel.pid_max = 4194304' | sudo tee /etc/sysctl.d/98-pid-max.conf
sudo sysctl --system
```

`-w` pokes `/proc/sys/kernel/pid_max` now; the drop-in plus `sysctl --system` makes it immediate *and* reboot-proof. No new mechanism — the value takes effect the instant `--system` runs and is replayed by `systemd-sysctl.service` on every boot.

## Ceiling 2 — `ulimit -u` / `RLIMIT_NPROC`

Live, for the current shell and processes it launches from now on:

```bash
# shell: as the workload's user
ulimit -u 32768        # raise the SOFT limit (up to the hard limit; root to exceed)
```

This affects **only this shell and its future children**. It does not reach back into an already-running service, another terminal, or a process that already started — and it does not survive logout, let alone reboot.

Persistent, via PAM:

```bash
# /etc/security/limits.d/data-processing.conf
dataproc   soft   nproc   32768
dataproc   hard   nproc   65536
```

`man 5 limits.conf`: `pam_limits` reads this **at login time**, applying the limits to the new session's leader process, which every child inherits. The consequence people trip on: a shell or service session that was **already open when you edited the file keeps its old limit** — the file only affects sessions that authenticate *after* it is in place. Log out and back in (or restart the service so it gets a fresh session) to pick it up. That is not a bug; it is `pam_limits` working as documented.

For a systemd *service* the equivalent is `LimitNPROC=` in the unit, not `limits.conf` (services do not go through `pam_limits`) — but for a service you usually want ceiling 3 instead.

## Ceiling 3 — `TasksMax=`

```bash
# shell: host, root
sudo systemctl edit data-ingest.service
```

```ini
[Service]
TasksMax=200000
```

```bash
sudo systemctl daemon-reload
sudo systemctl restart data-ingest.service
sudo systemctl show data-ingest.service -p TasksMax -p TasksCurrent
```

Two steps are non-optional and each does a distinct thing:

- **`daemon-reload`** — the manager re-parses unit files from disk into its in-memory graph. Without it the drop-in on disk is invisible to the running manager.
- **`restart`** — the cgroup limit is written when the unit's cgroup is created, at start. `daemon-reload` updates the *plan*; the already-running cgroup keeps the old `TasksMax` until the unit is restarted into a fresh cgroup.

`TasksMax=infinity` removes the per-unit cap entirely (falling back to ceilings 1 and 2). In production a large finite number is safer: it stops one runaway unit from consuming the whole machine's PID space, which is the safety rail `TasksMax=` exists to be.

## The triage order

When "cannot fork" lands, check in this order — widest scope to narrowest — and check **all three**, because a fix at one level is masked until the real clamp also moves:

```
  1. GLOBAL     sysctl -n kernel.pid_max
                vs  ps -eLf | wc -l          → is the whole pool full?

  2. PER-USER   sudo -u <user> bash -c 'ulimit -u'
                                             → is this account capped below what it needs?

  3. PER-UNIT   systemctl show <unit> -p TasksMax,TasksCurrent
                                             → if it's a service, is its cgroup capped
                                               independently of 1 and 2?
```

A diagnosis that inspects only `kernel.pid_max` answers about a third of the question; the other two ceilings have a habit of reappearing at the worst time.

> [!WARNING]
> - **`ulimit -u` in a script, expecting it to persist.** It dies with the shell. Persistence is `/etc/security/limits.d/` (login sessions) or `LimitNPROC=` (services).
> - **Editing `limits.conf` and testing in the same open session.** `pam_limits` ran at login, before your edit. Re-login to get the new value.
> - **`systemctl edit` without `daemon-reload` + `restart`.** The drop-in on disk does nothing to a cgroup already running under the old `TasksMax`.
> - **Raising only `pid_max`.** If the clamp is ceiling 2 or 3, the workload recovers only until the next spike, then fails identically.

> *Raise `pid_max` via sysctl drop-in, `ulimit -u` via `/etc/security/limits.d/` (re-login to apply), and `TasksMax=` via `systemctl edit` + `daemon-reload` + `restart`; triage global → per-user → per-unit and move every ceiling that is below what the workload needs.*

## Reference

- `man 5 limits.conf` — the `soft`/`hard`/`nproc` columns and the login-time application by `pam_limits`.
- `man systemd.exec` — `LimitNPROC=` for services (the unit-level `RLIMIT_NPROC`), distinct from `TasksMax=`.
- `man systemctl` — `edit`, `daemon-reload`, `show -p`; why a running unit needs a restart for a cgroup limit change.
