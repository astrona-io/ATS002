# systemd Timers

Astronaut, cron is one way to run a command on a schedule. **systemd timers** are the other, and the LFCS exam names both ("set up systemd services and timers"). systemd is the ship's duty officer, and a timer is an alarm clock on its desk that starts one station on schedule.

A timer is a pair of units: a `.timer` that holds the schedule and a `.service` that it starts. For that extra file you get logging in the journal, ordering between jobs, resource limits, catch-up for missed runs and a status for every run, which cron cannot give you. This module covers the two-unit model, the schedule syntax, converting a cron job to a timer, and running timers day to day.

## Learning objectives

After this module you can:

- Write a `.service` and `.timer` unit pair, and explain which unit you enable and why.
- Read `systemctl list-timers`: the NEXT, LAST and ACTIVATES columns.
- Write a schedule with `OnCalendar=` and test it with `systemd-analyze calendar`.
- Choose between a wall-clock trigger (`OnCalendar=`) and a monotonic one (`OnBootSec=`, `OnUnitActiveSec=`).
- Turn on catch-up for missed runs with `Persistent=true`, and spread load with `RandomizedDelaySec=`.
- Convert a cron job to a timer, and remove the cron line so the job does not run twice.
- Check the result of a scheduled run with `systemctl status`, `systemctl is-failed` and `journalctl -u <service>`.

## Before you start

Check that you have the knowledge and the tools this module expects.

### What you should already know

- **How to work in a shell.** You can type commands, use `sudo`, and save a file with a terminal editor.
- **What a systemd service is.** A service is a program systemd starts and watches, described by a unit file with sections such as `[Unit]` and `[Service]`.
- **What a cron line looks like.** A per-user cron line has five time fields (minute, hour, day of month, month, day of week) and then the command, for example `0 22 * * * /usr/local/sbin/backup.sh`.

### What you need

- A terminal on an Ubuntu 24.04 machine, if you want to try the examples in the parts. Any machine that runs systemd works.
- Or a running lab machine: the mission in this module gives you the exact commands to start it and open a terminal on it.

## How this module is laid out

1. [The Timer And Service Pair](./course-01-the-timer-and-service-pair.md): a `.timer` starts the `.service` with the same base name, you `enable --now` the timer and not the service, and `systemctl list-timers` shows what is armed.
2. [Schedule Expressions](./course-02-schedule-expressions.md): the `OnCalendar=` syntax tested with `systemd-analyze calendar`, the monotonic `OnBootSec=` and `OnUnitActiveSec=` family, and `Persistent=` and `RandomizedDelaySec=` for catch-up and spread.
3. [Converting A Cron Job To A Timer](./course-03-converting-cron-to-a-timer.md): when to choose a timer, mapping a cron schedule to `OnCalendar=`, and removing the cron line.
4. [Operating Timers](./course-04-operating-timers.md): forcing a run, reading results in the journal, `OnFailure=`, and `enable-linger` for user timers.
   - Mission: [systemd Timers Lab](./labs/lab-01/README.md)
5. [Wrap-Up: Mission Debrief](./course-05-wrap-up.md)

## Why this matters

On a modern Ubuntu machine, many of the system's own scheduled jobs are already timers, not cron lines. The exam can ask you to build a timer from scratch or to move a cron job into one. A timer that is enabled the wrong way, or a cron line left behind, fails without any error, so you need to know how to check the result.
