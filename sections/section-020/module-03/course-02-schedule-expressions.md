# Part 2 — Schedule expressions

> Prerequisite: [Part 1 — The timer and service pair](./course-01-the-timer-and-service-pair.md). Next: [Part 3 — Timers vs. cron, and operating them](./course-03-timers-vs-cron-and-operating.md).

The `[Timer]` section has two families of trigger: **wall-clock** (`OnCalendar=`) and **relative/monotonic** (`OnBootSec=` and friends). This part is both, the calendar syntax, and the flags that decide catch-up behaviour and jitter.

## `OnCalendar=` — wall-clock schedules

```ini
[Timer]
OnCalendar=*-*-* 04:00:00        # every day at 04:00
OnCalendar=Mon,Thu 11:15         # Mondays and Thursdays at 11:15
OnCalendar=*-*-01 00:00:00       # first of every month, midnight
OnCalendar=Mon *-*-* 00:00:00    # every Monday at midnight
OnCalendar=*-*-* *:0/15:00       # every 15 minutes
OnCalendar=hourly                # shortcut: *-*-* *:00:00
```

The full form is `DayOfWeek Year-Month-Day Hour:Minute:Second`. Any field can be `*` (any), a list (`Mon,Thu`), a range (`Mon..Fri`), or a step (`0/15` = 0,15,30,…). Named shortcuts: `minutely`, `hourly`, `daily`, `weekly`, `monthly`, `yearly`, `quarterly`.

**Always test an expression before trusting it:**

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

If it prints "Failed to parse", the expression is wrong — fix it here, not by waiting for a missed run. Multiple `OnCalendar=` lines in one timer are additive (it fires at each).

Timezone: `OnCalendar` is interpreted in the system timezone unless you append `UTC` or a zone. Keep this in mind on a box whose timezone differs from where the schedule was written.

## Monotonic triggers — relative to an event

```ini
[Timer]
OnBootSec=15min           # 15 min after boot
OnStartupSec=10min        # 10 min after systemd itself started (≈ boot, but not on reload)
OnActiveSec=5min          # 5 min after the timer unit is activated
OnUnitActiveSec=1h        # 1 h after the timer's own service last finished
OnUnitInactiveSec=30min   # 30 min after the service last went inactive
```

`OnUnitActiveSec=` is how you build "run every hour, measured from the end of the last run" — self-spacing, so a slow run does not pile up on the next. Combine `OnBootSec=` + `OnUnitActiveSec=` for "first run 15 min after boot, then every hour".

Accepted time units: `us`, `ms`, `s`, `min`, `h`, `d`, `w`, `month`, `year` — and combinations like `1h 30min`.

## Catch-up and jitter

```ini
[Timer]
OnCalendar=daily
Persistent=true            # if the machine was off at 04:00, run ASAP after next boot
RandomizedDelaySec=1h      # spread the actual fire time randomly across a 1h window
AccuracySec=1min           # how tightly to hit the target (default 1min; lower = more wakeups)
```

- **`Persistent=true`** — systemd records the last real run time on disk. If a scheduled run was missed because the machine was off (or asleep), it fires **once, immediately** after the next boot. This is the anacron-equivalent behaviour; without it, a missed run is simply skipped.
- **`RandomizedDelaySec=`** — adds a random offset up to that value, so a fleet of identical machines does not all hit a backup server at exactly 02:30.
- **`AccuracySec=`** — systemd batches timer wakeups for power efficiency; the default 1-minute slack is fine for almost everything. Set it small only for genuinely time-critical jobs.

> [!WARNING]
> - **Untested `OnCalendar=`** → a typo (`Mon,Thur` instead of `Mon,Thu`, or `11.15`) parses to nothing or the wrong time. Run `systemd-analyze calendar '<expr>'` first.
> - **Expecting cron-style catch-up by default** → systemd timers *skip* a missed run unless `Persistent=true` is set.
> - **`OnCalendar` on a box with a surprising timezone** → the schedule follows the system timezone; append `UTC` if that matters. Check `timedatectl`.
> - **Every machine firing at the exact same second** → add `RandomizedDelaySec=` for anything hitting a shared resource.

> *`OnCalendar=` takes `DoW Y-M-D H:M:S` (fields `*`/list/range/step, plus shortcuts like `daily`) — test it with `systemd-analyze calendar` — while `OnBootSec=`/`OnUnitActiveSec=` are monotonic; `Persistent=true` gives cron-style catch-up and `RandomizedDelaySec=` spreads load.*

## Reference

- `man systemd.time` — the full calendar and timespan grammar, every shortcut, timezone handling.
- `systemd-analyze calendar '<expr>' --iterations=5` — preview the next several fire times.
- `man systemd.timer` — `Persistent=`, `RandomizedDelaySec=`, `AccuracySec=`, `WakeSystem=`.
