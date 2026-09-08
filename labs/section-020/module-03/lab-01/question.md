# Question

Solve this question on: `terminal`

Two scheduling tasks on this host, both using **systemd timers** (not cron).

**1. A new scheduled report.**
Create a systemd timer that runs `/usr/local/sbin/report.sh` every **Monday
and Thursday at 11:15**. Requirements:
- a `report.service` (oneshot) that runs the script, and a `report.timer`
  that activates it;
- `OnCalendar=` set to that schedule (verify it with
  `systemd-analyze calendar`);
- `Persistent=true`, so a run missed while the machine was off is caught up
  after the next boot;
- the timer enabled so it survives a reboot, and started now.

**2. Convert an existing cron job to a timer.**
`/etc/cron.d/dbclean` currently runs `/usr/local/sbin/dbclean.sh` every 6
hours as root. Replace it with an equivalent systemd timer:
- a service that runs `dbclean.sh` and a timer that fires it every 6 hours;
- the timer enabled and started;
- **remove the cron job** so `dbclean.sh` no longer runs from two places.

Verify both with `systemctl list-timers`.
