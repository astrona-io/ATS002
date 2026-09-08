# systemd Timers

Cron is one way to run a command on a schedule; **systemd timers** are the other, and the LFCS objective names both ("set up systemd services and timers"). A timer is a pair of units — a `.timer` that carries the schedule and a `.service` it activates — and in exchange for that extra structure you get journal logging, dependency ordering, resource limits, missed-run catch-up, and per-run status that cron has no answer for. This module covers the two-unit model, the calendar and monotonic schedule syntax, and how to convert a cron job to a timer and operate it.

Three short parts; work them in order.

## How this module is organised

1. **[Part 1 — The timer and service pair](./course-01-the-timer-and-service-pair.md)** — a `.timer` activates the `.service` of the same base name, you `enable --now` the *timer* not the service, and `systemctl list-timers` is the operational view.
2. **[Part 2 — Schedule expressions](./course-02-schedule-expressions.md)** — `OnCalendar=` wall-clock syntax (tested with `systemd-analyze calendar`), the monotonic `OnBootSec=`/`OnUnitActiveSec=` family, and `Persistent=` / `RandomizedDelaySec=` for catch-up and jitter.
3. **[Part 3 — Timers vs. cron, and operating them](./course-03-timers-vs-cron-and-operating.md)** — when to pick a timer, converting a cron line to a `.service` + `.timer`, forcing a run, checking results in the journal, and `enable-linger` for user timers.

## Learning objectives

After this module you can:

- **Write** a `.service` + `.timer` unit pair and explain which unit you enable and why.
- **Read** `systemctl list-timers` — NEXT, LAST, and the ACTIVATES column.
- **Express** a schedule with `OnCalendar=` and verify it with `systemd-analyze calendar`.
- **Choose** between a wall-clock (`OnCalendar=`) and a monotonic (`OnBootSec=`/`OnUnitActiveSec=`) trigger.
- **Enable** cron-style catch-up with `Persistent=true` and spread load with `RandomizedDelaySec=`.
- **Convert** a cron job to a timer, removing the cron line so it does not fire twice.
- **Verify** a scheduled run's result with `systemctl status` / `is-failed` and `journalctl -u <service>`.

## Before you start

Assumed: a Linux shell, `sudo`, basic systemd unit-file syntax, and Module 1's cron material (this module is the systemd counterpart). Every command block states the shell and privilege it assumes and runs on any systemd host.

## Where this fits

This is the third module of the section — cron (Module 1) and timers here are the two scheduling mechanisms, and containers (Module 2) are the workload they most often schedule. The section capstone restarts a stopped container on a schedule; doing that with a `.timer` + `Restart=`-style watchdog service, rather than a cron loop, is the more idiomatic systemd approach and uses everything in this module.
