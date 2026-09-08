# Part 3 — Timers vs. cron, and operating them

> Prerequisite: [Part 2 — Schedule expressions](./course-02-schedule-expressions.md). Next: [Section 020 quiz](../quiz.md).

Both cron and systemd timers run a command on a schedule. This part is when each is the right tool, how to convert a cron job to a timer, and how to operate and verify a timer once it exists.

## What a timer gives you that cron does not

| | cron | systemd timer |
|---|---|---|
| Output/logging | mailed, or lost unless redirected | in the **journal**: `journalctl -u <name>.service` |
| Dependency ordering | none | `After=`, `Requires=`, `Wants=` on the service |
| Resource control | none | `MemoryMax=`, `CPUQuota=`, `Nice=`, sandboxing in the service unit |
| Missed-run catch-up | anacron, separately | `Persistent=true` |
| Overlap prevention | none (a slow run can double up) | `OnUnitActiveSec=` self-spaces; a still-running oneshot will not re-trigger |
| Randomized start | manual `sleep $((RANDOM…))` | `RandomizedDelaySec=` |
| Per-run status | none | `systemctl status <name>.service`, `is-failed` |

Cron is still fine for a trivial, self-contained script where none of the above matters. Reach for a timer when the job needs ordering, resource limits, real logging, or catch-up — or when a task explicitly says "systemd timer".

## Converting a cron job to a timer

A crontab line:

```cron
15 11 * * MON,THU  /usr/local/sbin/report.sh
```

becomes a `.service` + `.timer` pair:

```ini
# /etc/systemd/system/report.service
[Unit]
Description=Weekly report

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/report.sh
```

```ini
# /etc/systemd/system/report.timer
[Unit]
Description=Run the weekly report

[Timer]
OnCalendar=Mon,Thu 11:15
Persistent=true

[Install]
WantedBy=timers.target
```

Then:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now report.timer
sudo crontab -l                              # remove the old line
sudo crontab -e                              # ... so it does not run from two places
```

Mapping the schedule: cron `MIN HOUR DOM MON DOW` → `OnCalendar=DOW *-MON-DOM HOUR:MIN` (with `*` fields becoming `*`). `15 11 * * MON,THU` → `Mon,Thu *-*-* 11:15:00`, which normalises to `Mon,Thu 11:15`. **Delete the cron line** — like cron itself, systemd has no dedup, so leaving both makes the job fire twice.

## Operating a timer

```bash
# is it armed, and pointing at the right service?
systemctl list-timers report.timer

# force a run now, out of schedule (e.g. to test the service)
sudo systemctl start report.service

# did the last run succeed?
systemctl status report.service
systemctl is-failed report.service           # "active" if ok, "failed" if not

# the output of past runs
journalctl -u report.service --since today

# pause the schedule without deleting anything
sudo systemctl disable --now report.timer
```

A failing scheduled job does not announce itself — check `systemctl list-timers` (LAST column advancing) and `journalctl -u <service>` periodically, or add an `OnFailure=` handler to the service:

```ini
[Unit]
OnFailure=notify-admin@%n.service
```

## `.timer` enable persistence and user timers

- The `.timer` needs `[Install] WantedBy=timers.target` and `systemctl enable` for the schedule to survive a reboot. Without it the timer only runs until the next boot.
- **User timers** (`systemctl --user`) live in `~/.config/systemd/user/` and run only while that user has a session — unless you `sudo loginctl enable-linger <user>`, which keeps their user manager (and timers) running with no login. This is the systemd analogue of a per-user crontab.

> [!WARNING]
> - **Leaving the cron line in place after converting** → the job fires from both cron and the timer. Remove the crontab entry.
> - **`systemctl start report.timer` when you meant to test the job** → that arms the timer; to run the job now, `systemctl start report.service`.
> - **A user timer that stops when you log out** → run `loginctl enable-linger <user>` for it to keep firing.
> - **Assuming a failed run is visible** → it is silent. Watch `list-timers` / `journalctl -u <service>`, or wire `OnFailure=`.

> *Prefer a timer over cron when the job needs ordering, resource limits, journal logging, or `Persistent=` catch-up; convert by writing a oneshot `.service` + a `.timer` with the mapped `OnCalendar=`, `enable --now` the timer, and delete the cron line — then verify with `systemctl list-timers` and `journalctl -u <service>`.*

## Reference

- `man systemd.timer` / `man systemd.time` — the timer unit and schedule grammar.
- `man loginctl` — `enable-linger` for user timers that run without a login session.
- `man systemctl` — `list-timers`, `is-failed`, `start` (service vs timer), `disable --now`.
