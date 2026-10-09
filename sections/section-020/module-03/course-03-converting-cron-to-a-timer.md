# Converting A Cron Job To A Timer

Astronaut, cron and systemd timers both run a command on a schedule. A cron job is a standing order on the duty roster; a timer is an alarm clock on the duty officer's desk. This part shows when each one is the right tool, and how to turn a cron line into a `.service` and `.timer` pair without the job running twice.

## What a timer gives you that cron does not

A timer takes two files where cron takes one line. In return, systemd gives the job everything it gives any other service.

### Side by side

| | cron | systemd timer |
|---|---|---|
| Output and logging | mailed, or lost unless redirected | in the **journal**: `journalctl -u <name>.service` |
| Dependency ordering | none | `After=`, `Requires=`, `Wants=` on the service |
| Resource control | none | `MemoryMax=`, `CPUQuota=`, `Nice=` and sandboxing in the service unit |
| Missed-run catch-up | anacron, set up separately | `Persistent=true` |
| Overlap prevention | none (a slow run can double up) | a service that is still running is not started again; `OnUnitInactiveSec=` spaces runs from the end of the last one |
| Random start delay | a manual `sleep $((RANDOM…))` | `RandomizedDelaySec=` |
| Status of each run | none | `systemctl status <name>.service`, `systemctl is-failed` |

The journal is the ship's log, kept by `journald`. Cron is still fine for a small script that needs none of the above. Choose a timer when the job needs ordering, resource limits, real logging or catch-up, or when a task says "systemd timer".

## Converting a cron line

A conversion has three steps: write the service, write the timer with the matching schedule, and remove the cron line.

### The cron line you start from

Here is a crontab line that runs an archive script at 06:45 every Tuesday and Friday:

```cron
45 6 * * TUE,FRI  /usr/local/sbin/archive.sh
```

### The service and the timer

Save this as `/etc/systemd/system/archive.service`:

```ini
[Unit]
Description=Twice-weekly archive

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/archive.sh
```

Save this as `/etc/systemd/system/archive.timer`:

```ini
[Unit]
Description=Run the twice-weekly archive

[Timer]
OnCalendar=Tue,Fri 06:45
Persistent=true

[Install]
WantedBy=timers.target
```

Apply it:

```sh
sudo systemctl daemon-reload
sudo systemctl enable --now archive.timer
```

### Mapping the schedule

A cron line lists `MIN HOUR DOM MON DOW`. `OnCalendar=` wants `DOW *-MON-DOM HOUR:MIN`, and every `*` in cron stays `*`. So `45 6 * * TUE,FRI` becomes `Tue,Fri *-*-* 06:45:00`, which you can write short as `Tue,Fri 06:45`. Check it with `systemd-analyze calendar 'Tue,Fri 06:45'` before you rely on it.

### Remove the cron line

Like cron, systemd does not remove duplicates. If you leave the cron line in place, the job runs twice. Find it and delete it:

```sh
sudo crontab -l                              # remove the old line
sudo crontab -e                              # ... so it does not run from two places
```

If the line lives in a file under `/etc/cron.d/` instead of a crontab, delete that file or that one line. Then check that it is gone, for example with `sudo grep -rn 'archive.sh' /etc/crontab /etc/cron.d/`.

## Common pitfalls

> [!WARNING]
> - **Leaving the cron line in place after converting.** The job fires from both cron and the timer. Remove the cron entry.
> - **Copying the cron field order into `OnCalendar=`.** The order is different: weekday first, then the date, then the time. Test with `systemd-analyze calendar`.
> - **Enabling `archive.service` instead of `archive.timer`.** Only the timer carries the schedule.
