# Schedule Expressions

Astronaut, the time written on the alarm clock goes in the `[Timer]` section of the `.timer` unit. There are two families of trigger. **Wall-clock** triggers (`OnCalendar=`) fire at a time of day, like "Monday at 11:15". **Monotonic** triggers (`OnBootSec=` and the others) fire a fixed time after an event, like "15 minutes after boot". This part covers both, how to test a schedule, and the settings for missed runs and spread-out start times.

The lines below are pieces of a `[Timer]` section, not whole files. The `#` notes on the right are for reading only. systemd treats a line as a comment only when it starts with `#`, so leave those notes out of a real unit file.

## `OnCalendar=`: wall-clock schedules

`OnCalendar=` is the setting you will use most. It takes a calendar time, much like the time fields of a cron line.

### Examples first

```ini
[Timer]
OnCalendar=*-*-* 04:00:00        # every day at 04:00
OnCalendar=Mon,Thu 11:15         # Mondays and Thursdays at 11:15
OnCalendar=*-*-01 00:00:00       # first of every month, midnight
OnCalendar=Mon *-*-* 00:00:00    # every Monday at midnight
OnCalendar=*-*-* *:0/15:00       # every 15 minutes
OnCalendar=hourly                # shortcut: *-*-* *:00:00
```

The full form is `DayOfWeek Year-Month-Day Hour:Minute:Second`. Any field can be `*` (any value), a list (`Mon,Thu`), a range (`Mon..Fri`) or a step (`0/15` means 0, 15, 30, 45). The named shortcuts are `minutely`, `hourly`, `daily`, `weekly`, `monthly`, `yearly` and `quarterly`. If one timer has several `OnCalendar=` lines, it fires at each of them.

### Test an expression before you trust it

`systemd-analyze calendar` reads an expression the same way systemd will, and tells you when it fires next:

```bash
systemd-analyze calendar 'Mon,Thu 11:15'
```

```text
  Original form: Mon,Thu 11:15
Normalized form: Mon,Thu *-*-* 11:15:00
    Next elapse: Thu 2026-09-11 11:15:00 UTC
       (in UTC): Thu 2026-09-11 11:15:00 UTC
       From now: 2 days left
```

The dates in this sample are an example; your machine prints its own next date and time. The line to check is `Normalized form`: it shows how systemd understood your expression. If the tool prints "Failed to parse", the expression is wrong. Fix it now, not after a missed run. Add `--iterations=5` to see the next five times it fires.

### Time zones

`OnCalendar=` follows the system time zone, unless you add `UTC` or a zone name at the end. Keep this in mind on a machine whose time zone differs from the place where the schedule was written. `timedatectl` shows the machine's time zone.

## Monotonic triggers: relative to an event

A monotonic trigger counts time from something that happened on the ship, not from the clock on the wall.

### The family

```ini
[Timer]
OnBootSec=15min           # 15 min after boot
OnStartupSec=10min        # 10 min after systemd itself started (≈ boot, but not on reload)
OnActiveSec=5min          # 5 min after the timer unit is activated
OnUnitActiveSec=1h        # 1 h after the timer's own service last started
OnUnitInactiveSec=30min   # 30 min after the service last went inactive
```

`OnUnitActiveSec=` repeats a job: "run again one hour after the service last started". `OnUnitInactiveSec=` counts from the moment the last run ended instead, so a slow run pushes the next one back. Combine `OnBootSec=` with `OnUnitActiveSec=` for "first run 15 minutes after boot, then every hour".

The time units systemd accepts are `us`, `ms`, `s`, `min`, `h`, `d`, `w`, `month` and `year`, and you can combine them, as in `1h 30min`.

## Missed runs and spread-out start times

Three more settings decide what happens when the ship was off, and how exactly the alarm rings.

### Catch-up, random delay and accuracy

```ini
[Timer]
OnCalendar=daily
Persistent=true            # if the machine was off at 04:00, run ASAP after next boot
RandomizedDelaySec=1h      # spread the actual fire time randomly across a 1h window
AccuracySec=1min           # how tightly to hit the target (default 1min; lower = more wakeups)
```

- **`Persistent=true`**: systemd writes the time of the last real run to disk. If a run was missed because the machine was off or asleep, the timer fires **once, straight away** after the next boot. This is what anacron does for cron. Without it, a missed run is simply skipped.
- **`RandomizedDelaySec=`**: adds a random delay up to that value, so a fleet of identical machines does not hit a backup server at exactly 02:30.
- **`AccuracySec=`**: systemd groups timer wake-ups together to save power. The default of one minute is fine for almost everything. Set it lower only for jobs where the exact second matters.

## Common pitfalls

> [!WARNING]
> - **An untested `OnCalendar=`.** A typo (`Mon,Thur` instead of `Mon,Thu`, or `11.15`) parses to nothing or to the wrong time. Run `systemd-analyze calendar '<expression>'` first.
> - **Expecting catch-up by default.** systemd timers *skip* a missed run unless `Persistent=true` is set.
> - **`OnCalendar=` on a machine with an unexpected time zone.** The schedule follows the system time zone. Add `UTC` if that matters, and check with `timedatectl`.
> - **Every machine firing at the same second.** Add `RandomizedDelaySec=` to anything that hits a shared resource.
> - **A `#` note at the end of a unit file line.** systemd reads it as part of the value. Put comments on their own line.
