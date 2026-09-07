# Part 1 — The service manager and unit state

> Prerequisite: [module landing page](./course.md). Next: [Part 2 — The effective unit definition](./course-02-the-effective-unit-definition.md).

Before you can read a failure you need to know what `systemctl` is talking to and what the words in its output mean. This part settles that: `systemctl` is a thin client, PID 1 is the manager, and every service moves through a small fixed set of **states**. Once you can name the state a unit is stuck in and why, the rest of the module is about closing the gap.

## `systemctl` is a client; PID 1 is the manager

Concrete: you run `systemctl restart apache2` and get a prompt back almost immediately, sometimes with `Job for apache2.service failed`.

What happened underneath: `systemctl` opened a socket to **`systemd`, running as PID 1**, and submitted a **job** — "bring `apache2.service` to `active`". PID 1 did the work (ran the `ExecStart=` command, watched it, timed it), recorded the outcome, and `systemctl` printed a summary of that recorded outcome. `systemctl` itself started nothing and watched nothing.

```
  systemctl restart apache2
        │  (D-Bus / private socket)
        ▼
  systemd (PID 1) ──► fork+exec ExecStart=  ──►  service process
   the manager   ◄── exit status / watchdog / timeout
        │
        ▼
   records: ActiveState, SubState, Result, Main PID, exit code
        │
  systemctl status / show / is-active  ── read those records back
```

The practical consequence: **everything `systemctl status` shows you is a record PID 1 already wrote.** The service does not have to still be running for the diagnosis to be there. A unit that failed and exited 40 seconds ago still has its full outcome in the manager's memory (and the journal — Part 3).

## The unit lifecycle

A service unit is always in exactly one **`ActiveState`**. The states and the moves between them:

```
                    start job
   inactive ───────────────────────►  activating
      ▲                                   │  ExecStartPre / ExecStart running
      │ stop job completes                │
      │                                   ▼
  deactivating ◄───────────────────────  active   ◄───┐
      │            stop job                │          │ (Type=notify: READY=1;
      │                                    │          │  Type=forking: parent exits;
      │  ExecStart failed, or             │          │  Type=simple: exec succeeded)
      │  timeout, or killed               ▼          │
      └──────────────────────────────►  failed ──────┘
                                     (start job later)
```

- **`inactive`** — not running, nothing wrong. The resting state.
- **`activating`** — a start job is in progress: `ExecStartPre=` then `ExecStart=` are running, and for `Type=notify`/`forking` the manager is *waiting for a readiness signal*.
- **`active`** — the start job completed successfully. What "successfully" means depends on `Type=` (see Part 4).
- **`deactivating`** — a stop job is in progress.
- **`failed`** — a start job did not complete: `ExecStart=` exited non-zero, or the readiness deadline (`TimeoutStartSec=`) passed, or the process was killed. **A unit sits in `failed` until something starts it again or you `reset-failed` it.**

`ActiveState` has a companion, **`SubState`**, that carries the type-specific detail: `running`, `exited` (a `Type=oneshot`/`forking` unit whose process finished but the unit is still "active"), `dead`, `failed`, `auto-restart`, `start-pre`. `systemctl --failed` shows both columns (`ACTIVE` = ActiveState, `SUB` = SubState).

## Why a unit reached `failed`: the `Result` tag

When `ActiveState=failed`, the manager also records a **`Result`** — the *category* of failure. This is the single most useful field for choosing what to look at next:

| `Result:` | What it means | Part 4 shape |
|---|---|---|
| `exit-code` | `ExecStart=` ran and returned non-zero | bad config / bad `ExecStart` |
| `timeout` | never signalled readiness within `TimeoutStartSec=` | dependency / readiness |
| `signal` | killed by a signal (often `SIGSEGV`, or `SIGKILL` from a timeout escalation) | crash / OOM |
| `core-dump` | crashed and dumped core | crash |
| `oom-kill` | the kernel OOM killer took it | resource pressure |
| `resources` | the manager could not set the unit up (bad `User=`, missing binary, unwritable `RuntimeDirectory=`) | permission / path |
| `exec-condition` / `protocol` | `ExecCondition=` failed / readiness protocol violated | conditional / type mismatch |

## Reading `systemctl status`

```bash
# shell: any host, unprivileged (root only needed to change state)
systemctl status apache2
```

```text
× apache2.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/apache2.service; enabled; preset: enabled)
     Active: failed (Result: exit-code) since Mon 2026-09-07 09:12:04 UTC; 30s ago
    Process: 4491 ExecStart=/usr/sbin/apachectl start (code=exited, status=1/FAILURE)
   Main PID: 4491 (code=exited, status=1/FAILURE)
        CPU: 42ms

Sep 07 09:12:04 web01 apachectl[4494]: (98)Address already in use: AH00072: make_sock: could not bind to [::]:80
Sep 07 09:12:04 web01 apachectl[4494]: no listening sockets available, shutting down
Sep 07 09:12:04 web01 systemd[1]: apache2.service: Failed with result 'exit-code'.
```

Line by line:

- **`× apache2.service`** — the leading glyph is the state: `●` active, `×` failed, `○` inactive, `↻` reloading. Fast visual triage in `systemctl --failed` output.
- **`Loaded:`** — did the manager find a unit file, *which* file, and the enablement state (`enabled` / `disabled` / `static` / `masked`). `Loaded: not-found` → you have the unit name wrong; nothing else matters yet.
- **`Active:`** — `ActiveState (Result: …) since <timestamp>`. Here `failed (Result: exit-code)`.
- **`Process:`** — each `Exec*=` line the manager ran, with `code=exited, status=N` (the process's own exit code) or `code=killed, signal=SEGV`. `status=1/FAILURE` is exactly what `/usr/sbin/apachectl start` would return if you ran it by hand.
- **`Main PID:`** — the tracked main process and how it ended.
- **The indented lines** — the **last ~10 journal entries** for this unit, no more. `status` is a summary, not the log; Part 3 is the log.

## The scriptable one-word answers

`status` is for humans. For a script or a quick check, three commands that print one word and set an exit code:

```bash
systemctl is-active  apache2     # active | inactive | activating | failed   (exit 0 iff active)
systemctl is-enabled apache2     # enabled | disabled | static | masked      (exit 0 iff enabled)
systemctl is-failed  apache2     # failed | active | ...                      (exit 0 iff failed)
```

And the whole-system view — every unit currently in `failed`:

```bash
systemctl --failed
```

```text
  UNIT            LOAD   ACTIVE SUB    DESCRIPTION
× apache2.service loaded failed failed The Apache HTTP Server

1 loaded units listed.
```

On this Ubuntu image the web server unit is `apache2`; on RHEL-family systems it is `httpd`. Every `systemctl` subcommand takes the unit name with or without the `.service` suffix.

> [!TIP]
> **Try it — read a real failed unit.** In the playground `apache2` is already `failed`. On the host (`astrona ssh astro-systemd-service-debugging`):
>
> ```bash
> systemctl status apache2
> systemctl is-active apache2; systemctl is-enabled apache2; systemctl is-failed apache2
> systemctl --failed
> ```
>
> Expect something like:
>
> ```text
> × apache2.service - The Apache HTTP Server
>      Active: failed (Result: exit-code) since ...
>     Process: ... ExecStart=/usr/sbin/apachectl start (code=exited, status=1/FAILURE)
> ...
> failed
> disabled
> failed
>   UNIT            ... ACTIVE SUB    DESCRIPTION
> × apache2.service ... failed failed The Apache HTTP Server
> ```
>
> `Active: failed (Result: exit-code)` — the process ran and returned non-zero. `is-active`/`is-enabled`/`is-failed` each print one word. The embedded lines under `status` are a tail, not the whole log — Part 3 gets the rest.

> [!WARNING]
> The lines under a `systemctl status` report are a **truncated tail**, not "the logs". If the root-cause message scrolled past more than ~10 lines before the final failure, it is not shown here — go to `journalctl -u` (Part 3). Treating the `status` tail as complete is how people miss a cause that is sitting one screen up in the journal.

> *`systemctl` is a client of PID 1, which records each unit's `ActiveState`, `SubState`, and `Result`; a `failed` unit stays failed until restarted, and the `Result` tag (`exit-code`, `timeout`, `signal`, `resources`, …) tells you which kind of failure to chase.*

## Reference

- `man systemd.service` — the `Type=` values and which one defines "started successfully" for a given service.
- `man systemctl` — `status`, `is-active`/`is-enabled`/`is-failed`, `--failed`, `list-units`; the `--state=` and `--type=` filters.
- `man systemd` — the manager itself: what PID 1 does, the job queue, `ActiveState` vs `SubState`.
