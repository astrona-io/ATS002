# Part 4 — Failure shapes, and proving the fix

> Prerequisite: [Part 3 — Reading the journal](./course-03-reading-the-journal.md). Next: [Section 010 quiz](../quiz.md).

Parts 1–3 gave you the reading tools. This part is the pattern-match: almost every "won't start" is one of four shapes, each a direct consequence of *how* a start job runs, and each with a distinct signature in `systemctl status` / `journalctl`. Then the other half — proving a fix is real, and the difference between "running now" and "starts on boot" that a task almost always checks both of.

## How a start job runs (so the shapes make sense)

```
  systemctl start apache2
        │
  ExecStartPre=  ──► non-zero? ──► failed (Result: exit-code)
        │
  fork + exec ExecStart=
        │
        ├─ Type=simple    : "active" the instant exec succeeds
        ├─ Type=exec      : "active" once exec() completes
        ├─ Type=forking   : "active" when the ORIGINAL process exits and a child remains
        ├─ Type=notify    : "active" when the service sends sd_notify READY=1
        └─ Type=oneshot   : "active"/"exited" when the process exits 0
        │
  readiness not reached within TimeoutStartSec=  ──► SIGTERM, then SIGKILL ──► failed (Result: timeout)
        │
  process exits non-zero later  ──► failed (Result: exit-code / signal)
```

Every shape below is one of these arrows going wrong.

## Shape 1 — bad config or bad `ExecStart`

`ExecStart=` runs, the program rejects its own configuration, exits non-zero. Signature: `Result: exit-code`, `status=1..N`, and **the program's own parser error** in the journal (`journalctl -eu apache2`).

Confirm it without touching the service — most servers ship a config check, and systemd has a generic one:

```bash
# shell: host, root
sudo apache2ctl configtest         # Debian/Ubuntu;  'httpd -t' or 'nginx -t' elsewhere
sudo systemd-analyze verify apache2.service   # checks the UNIT file itself for errors
```

```text
AH00526: Syntax error on line 12 of /etc/apache2/sites-enabled/000-default.conf:
Invalid command 'DocumentRoott', perhaps misspelled or defined by a module not included
```

Fix the file, re-run the check until it is clean, then `systemctl restart`. If `systemd-analyze verify` flags the *unit* (bad `ExecStart=` path, unknown directive), that is a Part 2 edit plus `daemon-reload`.

## Shape 2 — the address is already in use

`ExecStart=` runs, the daemon calls `bind()`, the kernel returns `EADDRINUSE`. Signature: `(98)Address already in use`, `AH00072`, `could not bind`, `no listening sockets`. Find the current owner of the port with `ss` — *socket statistics*, the `netstat` replacement:

```bash
sudo ss -ltnp 'sport = :80'
```

```text
State  Recv-Q Send-Q Local Address:Port Peer Address:Port Process
LISTEN 0      511          0.0.0.0:80        0.0.0.0:*     users:(("nginx",pid=3901,fd=6))
```

`-l` listening sockets, `-t` TCP, `-n` numeric ports (no `:http`), `-p` the owning process. Here `nginx` (pid 3901) holds `:80`. Stop it, reassign one of the two services, or (if it is a stale duplicate) clean it up — then restart apache2.

> [!TIP]
> **Try it — journal names the symptom, `ss` names the culprit.** The playground's `apache2` fails with exactly this shape. On the host:
>
> ```bash
> systemctl status apache2 | grep -i 'bind\|address'
> sudo ss -ltnp 'sport = :80'
> ```
>
> Expect something like:
>
> ```text
> ... (98)Address already in use: AH00072: make_sock: could not bind to address [::]:80
> LISTEN 0 5 0.0.0.0:80 0.0.0.0:* users:(("socat",pid=812,fd=5))
> ```
>
> A `socat` process (the playground's `port80-hog.service`) is holding `:80`. The next checkpoint clears it and proves the fix.

## Shape 3 — a dependency failed, or readiness timed out

Two sub-cases, both showing as `Result: timeout` or `Failed to start` with no program error of its own:

- **A `Requires=` unit failed.** `Requires=` propagates failure: if `apache2.service` requires `mysql.service` and MySQL is `failed`, apache2 is pulled down with it. `After=` alone only orders start-up, it does not propagate failure.
- **Readiness never signalled.** A `Type=notify` service that never calls `sd_notify(READY=1)`, or a `Type=forking` one whose parent never exits, sits in `activating` until `TimeoutStartSec=` (default 90s) expires, then the manager kills it → `Result: timeout`.

```bash
systemctl list-dependencies --failed apache2   # any failed unit in the tree?
systemctl show apache2 -p Type -p TimeoutStartUSec -p Requires -p After
```

Fix the upstream unit first, or correct the `Type=` if it does not match how the service actually backgrounds.

## Shape 4 — permission, path, or MAC

The manager cannot set the unit up, or the process is denied a path it needs. Signature: `Result: resources` (setup failure — bad `User=`, missing `ExecStart=` binary, unwritable `RuntimeDirectory=`), or a running process getting `EACCES` / `Permission denied` / `Read-only file system` on a path.

Two layers to check, in order:

1. **The unit's own sandbox.** Directives like `ProtectSystem=strict`, `ProtectHome=`, `ReadOnlyPaths=`, `ReadWritePaths=`, `PrivateTmp=` make parts of the filesystem invisible or read-only *to that service only*. `systemctl show apache2 | grep -E 'Protect|ReadWrite|ReadOnly|PrivateTmp'`. A path the service needs must be in `ReadWritePaths=`.
2. **Mandatory Access Control.** DAC (`ls -l`) looks correct and it is still denied → check the kernel log for an LSM denial:

   ```bash
   sudo journalctl -k | grep -E 'apparmor="DENIED"|avc:  denied'
   ```

   That hands off to **Section 040** — an AppArmor profile or SELinux label with no rule for the path the service was reconfigured to use.

## The `Restart=` flap

A unit with `Restart=always` / `on-failure` and a fast-failing `ExecStart=` does not fail once — it **flaps**: `activating (auto-restart)` → `failed` → `activating` → … until it trips the rate limit `StartLimitBurst=` (default 5) within `StartLimitIntervalSec=` (default 10s). Then:

```text
apache2.service: Start request repeated too quickly.
apache2.service: Failed with result 'start-limit-hit'.
```

`start-limit-hit` is not the root cause — it is the manager giving up. Find the real failure in the journal from *before* the flapping started, fix it, then clear the latched state:

```bash
sudo systemctl reset-failed apache2
sudo systemctl start apache2
```

## Proving the fix

Match the apply step to what you changed:

```bash
# changed a service config file (e.g. /etc/apache2/...):
sudo systemctl restart apache2

# changed the unit or a drop-in (Part 2):
sudo systemctl daemon-reload
sudo systemctl restart apache2
```

Then verify — three questions, three checks, none of which is "it didn't print an error":

```bash
systemctl is-active apache2       # -> active
systemctl status apache2          # -> active (running), fresh Main PID, recent 'since'
journalctl -u apache2 -n 20       # -> clean start lines, nothing after the restart timestamp
```

## `active` is not `enabled`

They answer different questions and a task that says "running and starts on boot" checks **both**:

| | `systemctl is-active` | `systemctl is-enabled` |
|---|---|---|
| Question | is it running *right now*? | will it start *on the next boot*? |
| Set by | `start` / `stop` / `restart` | `enable` / `disable` |
| Mechanism | a running process tracked by PID 1 | a symlink under `/etc/systemd/system/<target>.wants/` pointing at the unit, per its `[Install] WantedBy=` |

```bash
sudo systemctl enable --now apache2     # enable (create the .wants symlink) AND start, in one
systemctl is-enabled apache2            # enabled
systemctl is-active  apache2            # active
```

A unit can be `active` but `disabled` (running now, gone after reboot — the classic "I only ran `start`"), or `enabled` but `inactive` (symlink present, will start next boot, not running yet). `enable --now` / `disable --now` set both together.

> [!TIP]
> **Try it — fix, verify, and make it stick.** Following straight on from the port checkpoint:
>
> ```bash
> sudo systemctl stop port80-hog.service        # free :80
> sudo systemctl restart apache2                 # config-level fix -> just restart
> systemctl is-active apache2
> systemctl is-enabled apache2
> sudo systemctl enable --now apache2
> systemctl is-enabled apache2
> ```
>
> Expect something like:
>
> ```text
> active
> disabled
> Created symlink /etc/systemd/system/multi-user.target.wants/apache2.service -> ...
> enabled
> ```
>
> After the restart it is `active` but still `disabled` — running now, gone after a reboot. `enable --now` creates the `.wants` symlink so it also comes up on boot. "Running and starts on boot" needs both, and `is-active` / `is-enabled` are the two separate checks.

> [!WARNING]
> Common pitfalls, one line each:
> - **`status` tail read as the full log** — it is ~10 lines; use `journalctl -u` (Part 1, Part 3).
> - **Edited the unit, skipped `daemon-reload`** — manager still runs the old plan (Part 2).
> - **`daemon-reload` expected to restart the service** — it only updates the plan; still need `restart` (Part 2).
> - **Reading the cascade bottom-up** — `Failed to start` is the least specific line; start from the first concrete error (Part 3).
> - **`-p err` hid the reason** — widen the priority filter (Part 3).
> - **Fixed while flapping without `reset-failed`** — `start-limit-hit` stays latched until you clear it.
> - **Ran `start`, called it done** — not `enabled`, so it dies at the next reboot. Use `enable --now`.

> *The four shapes — bad config (`exit-code`), port taken (`EADDRINUSE`), dependency/readiness (`timeout`), permission/MAC (`resources`/`EACCES`) — each follow from a stage of the start job; after fixing, match the apply step to what changed, verify with `is-active` + `status` + `journalctl`, and set `enable --now` so it survives a reboot.*

## Reference

- `man systemd.service` — `Type=`, `Restart=`, `TimeoutStartSec=`, `ExecStartPre=`; the mechanics behind shapes 1 and 3.
- `man systemd.exec` — `User=`, `ProtectSystem=`, `ReadWritePaths=`, `RuntimeDirectory=`; the sandbox directives behind shape 4.
- `man systemd.unit` — `Requires=` vs `Wants=` vs `After=`, and `[Install]` / `WantedBy=` that `enable` acts on.
- `man systemd-analyze` — `verify` a unit, `security` a unit's sandbox score, `blame` / `critical-chain` for slow boots.
