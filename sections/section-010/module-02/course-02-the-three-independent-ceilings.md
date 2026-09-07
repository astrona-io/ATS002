# Part 2 — The three independent ceilings

> Prerequisite: [Part 1 — The shared PID pool and confirming exhaustion](./course-01-the-shared-pid-pool.md). Next: [Part 3 — Raising each ceiling, in order](./course-03-raising-each-ceiling-in-order.md).

A `fork()` does not check one limit. It checks three, enforced by three different kernel subsystems, and it fails if **any** of them is at capacity. This part is each ceiling: what enforces it, what scope it applies to, and where its persistent setting lives. Part 3 raises them.

## Concrete: the same failure, three possible causes

A data-processing job run as user `dataproc` throws `pthread_create failed` after ~4000 threads. `kernel.pid_max` is `4194304` and `ps -eLf | wc -l` shows 9000 tasks system-wide. The pool is nowhere near full — so the clamp is one of the *narrower* two.

## The three ceilings, side by side

```
  clone()/fork() must pass ALL THREE or it returns EAGAIN:

  ┌───────────────────────────────────────────────────────────────┐
  │ 1. kernel.pid_max      system-wide task-slot pool             │
  │    scope: the whole machine                                    │
  │    enforced by: the PID allocator                              │
  │    persists in: /etc/sysctl.d/*.conf                           │
  ├───────────────────────────────────────────────────────────────┤
  │ 2. RLIMIT_NPROC (ulimit -u)   processes+threads per real UID   │
  │    scope: everything owned by one user, across all its sessions│
  │    enforced by: the kernel, per-credential, at clone() time    │
  │    persists in: /etc/security/limits.d/*.conf  (via pam_limits)│
  ├───────────────────────────────────────────────────────────────┤
  │ 3. TasksMax=   processes+threads in one systemd unit's cgroup  │
  │    scope: one service unit and everything it spawns            │
  │    enforced by: the cgroup pids controller                     │
  │    persists in: a unit drop-in / /etc/systemd/system.conf      │
  └───────────────────────────────────────────────────────────────┘

  the effective limit is the LOWEST of the three that applies to you
```

### Ceiling 1 — `kernel.pid_max` (global)

Covered in Part 1. It is a sysctl, machine-wide, and it is the *only* one of the three that widening helps when the pool itself is genuinely full. Widening it does nothing for a workload clamped by ceilings 2 or 3.

### Ceiling 2 — `ulimit -u` / `RLIMIT_NPROC` (per user)

```bash
# shell: as the user running the workload
ulimit -u        # soft limit — the one enforced now
ulimit -Hu       # hard limit — the ceiling the soft one may be raised to without root
```

```text
7877
15000
```

`man bash`, `SHELL BUILTIN COMMANDS` → `ulimit`, documents `-u` as "max user processes". The kernel enforces it as **`RLIMIT_NPROC`**, counted against the **real UID** of the calling process — so it caps the total number of processes and threads that user owns *across every session and service they are running*, not per shell. It is a completely separate accounting path from `pid_max`: you can be miles under `pid_max` and pinned against `RLIMIT_NPROC`.

Soft vs hard: the soft limit is enforced; an unprivileged process may raise its own soft limit up to the hard limit but not above; root can raise the hard limit.

### Ceiling 3 — `TasksMax=` (per systemd unit)

If the workload runs as a systemd service there is a third cap, in the cgroup layer:

```bash
# shell: any host
systemctl show data-ingest.service -p TasksMax -p TasksCurrent
```

```text
TasksMax=9830
TasksCurrent=4102
```

`man systemd.resource-control` → `TasksMax=` counts every process **and thread** in the unit's cgroup (via the cgroup `pids` controller) — Part 1's "threads count too", enforced at unit scope. A unit with no explicit `TasksMax=` inherits `DefaultTasksMax=` from `/etc/systemd/system.conf`, which is commonly **15% of `kernel.pid_max`**, computed once at manager start. So raising `pid_max` nudges that default up — but not live-linked, and 15% of even a large `pid_max` is often still below what a genuinely thread-heavy unit needs.

## Why "fixed it, broke again in an hour"

The classic failure: an incident is diagnosed as PID exhaustion, someone raises `pid_max` to the millions, the workload recovers because a transient spike passed — and an hour later it hits `RLIMIT_NPROC` or `TasksMax=` and fails again with the same message. The three ceilings are independent; only the lowest one that applies to your workload actually matters, and widening a higher one is invisible until the real clamp is also moved.

> [!WARNING]
> - **`ulimit -u` is per real UID, not per shell.** All of a user's sessions and services share the count. Two heavy jobs under the same account compete for it.
> - **`TasksMax=` counts threads.** A unit at `TasksCurrent` near `TasksMax` with only a handful of *processes* is thread-bound, not process-bound.
> - **`DefaultTasksMax` is a snapshot, not a link.** Raising `pid_max` after the manager started does not retroactively raise units already running under the old default.

> *A `fork()` must clear all three of `kernel.pid_max` (machine), `RLIMIT_NPROC`/`ulimit -u` (per real UID, all sessions), and `TasksMax=` (per unit cgroup, threads included) — the lowest one that applies is the real limit, and each persists in a different file.*

## Reference

- `man 5 limits.conf` — `nproc`, soft vs hard, and that `pam_limits` reads it at login.
- `man systemd.resource-control` — `TasksMax=`, `DefaultTasksMax=`, and the cgroup `pids` controller behind them.
- `man 2 setrlimit` — `RLIMIT_NPROC` semantics: counted per real user ID, causes `fork()` `EAGAIN`.
