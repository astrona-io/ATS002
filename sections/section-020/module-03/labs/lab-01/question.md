# Question

Solve this question on: `terminal`

Astronaut, this ship has two maintenance jobs that must run on schedule, and both must use **systemd timers** (not cron).

**1. A new scheduled report.**
Create a systemd timer that runs `/usr/local/sbin/report.sh` every **Monday
and Thursday at 11:15**. Requirements:
- a service named `report.service` (a oneshot service is the usual choice) that runs the script, and a timer named `report.timer` that starts it;
- `OnCalendar=` set to that schedule (check it with `systemd-analyze calendar`);
- `Persistent=true`, so a run missed while the machine was off is caught up after the next boot;
- the timer enabled, so it survives a reboot, and started now.

**2. Convert an existing cron job to a timer.**
`/etc/cron.d/dbclean` currently runs `/usr/local/sbin/dbclean.sh` every 6
hours as root. Replace it with an equivalent systemd timer:
- a service that runs `/usr/local/sbin/dbclean.sh`, and a timer that starts it every 6 hours;
- the timer enabled and started;
- **remove the cron job**, so `dbclean.sh` no longer runs from two places. No cron entry that mentions `dbclean` may remain in `/etc/crontab`, in `/etc/cron.d/` or in any user's crontab.

Check both with `systemctl list-timers`.
<!-- curriculum-links -->

## Related lessons and assessment

Read [module-03](../../course.md).

The grader checks:

- Confirms report.timer + report.service exist, the timer is enabled and active, activates report.service, uses OnCalendar Mon,Thu 11:15, and has Persistent=true.
- Confirms the dbclean cron job was removed and replaced by an enabled, active systemd timer running dbclean.sh every 6 hours, activating a dbclean service.

Use the inspection commands in the solution to check your work. Submit when you have finished; submission ends this environment.
