# Part 1 — The timer and service pair

> Prerequisite: [module landing page](./course.md). Next: [Part 2 — Schedule expressions](./course-02-schedule-expressions.md).

A systemd timer is not a self-contained job like a cron line — it is one unit that *activates another*. Getting the two-unit relationship right, and knowing which one to enable, is the whole foundation of this module.

## A timer activates a service of the same name

Concrete: you want `/usr/local/sbin/backup.sh` to run every night. You write **two** unit files:

```ini
# /etc/systemd/system/nightly-backup.service
[Unit]
Description=Nightly backup

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/backup.sh
```

```ini
# /etc/systemd/system/nightly-backup.timer
[Unit]
Description=Run the nightly backup

[Timer]
OnCalendar=*-*-* 02:30:00
Persistent=true

[Install]
WantedBy=timers.target
```

The rule: **`nightly-backup.timer` activates `nightly-backup.service`** — same base name, different suffix. When the timer fires, it does the equivalent of `systemctl start nightly-backup.service`.

```
  timers.target  (reached at boot)
        │  pulls in every enabled *.timer
        ▼
  nightly-backup.timer   ──[Timer] elapses──►  systemctl start nightly-backup.service
        │                                              │
   [Install] WantedBy=timers.target              Type=oneshot ExecStart=…
```

To pair a timer with a differently-named service, set `Unit=` in the `[Timer]` section explicitly. Without it, the base-name match is automatic.

## Enable and start the *timer*, never the service

```bash
# shell: any systemd host, root
sudo systemctl daemon-reload           # after creating/editing unit files
sudo systemctl enable --now nightly-backup.timer
```

- **`enable`** creates the symlink under `timers.target.wants/` so the timer is armed on every boot.
- **`--now`** also starts it this session.
- You enable the **`.timer`**. The `.service` stays `inactive (dead)` between runs — that is correct; it is `oneshot` and only runs when the timer (or you) starts it. Enabling the `.service` itself would try to run it at every boot, which is not what a schedule means.

`systemctl status nightly-backup.timer` shows when it last fired and when it fires next. `systemctl status nightly-backup.service` shows the result of the last run.

## `systemctl list-timers` — the operational view

```bash
systemctl list-timers
```

```text
NEXT                        LEFT       LAST                        PASSED    UNIT                   ACTIVATES
Wed 2026-09-09 02:30:00 UTC  14h left   Tue 2026-09-08 02:30:00 UTC  9h ago    nightly-backup.timer   nightly-backup.service
```

- **NEXT / LEFT** — when it next fires.
- **LAST / PASSED** — when it last fired.
- **ACTIVATES** — the service it starts. Confirm this column matches the service you intended.

`systemctl list-timers --all` also shows disabled timers. This command is the fastest check that a timer you set up is actually armed and pointing at the right service.

> [!WARNING]
> - **Enabling the `.service` instead of the `.timer`** → the job runs once at every boot and never on schedule. Enable the `.timer`.
> - **Forgetting `systemctl daemon-reload`** after writing the unit files → systemd does not see them yet; `enable` fails with "Unit … not found".
> - **The `.timer` has no `[Install]` section** → `systemctl enable` has nothing to link; it will not survive a reboot. Add `WantedBy=timers.target`.
> - **Base names do not match and no `Unit=`** → the timer fires but activates nothing (or the wrong unit). Match the names, or set `Unit=` explicitly.

> *A `*.timer` unit activates the `*.service` of the same base name (or the one named in `Unit=`); you `systemctl enable --now` the **timer**, the service stays dormant between runs, and `systemctl list-timers` shows NEXT/LAST and which service each timer ACTIVATES.*

## Reference

- `man systemd.timer` — the `[Timer]` section, the base-name activation rule, `Unit=`.
- `man systemd.service` — `Type=oneshot` and why a scheduled job is usually oneshot.
- `man systemctl` — `list-timers`, `enable`/`disable`, `daemon-reload`.
