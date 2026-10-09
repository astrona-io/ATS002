# Wrap-Up: Mission Debrief

Well flown, astronaut. You have finished every part and the mission in this module. Before you move on, look back at what you learned, check yourself, and clean up anything still running.

## What you learned

This module was about systemd's alarm clocks: the timer and service pair, the schedule syntax, converting cron jobs, and operating timers day to day.

**From [The Timer And Service Pair](./course-01-the-timer-and-service-pair.md):**

- A `.timer` starts the `.service` with the same base name, unless `Unit=` names another one.
- A scheduled job is usually a `Type=oneshot` service.
- Run `systemctl daemon-reload` after writing unit files, then `systemctl enable --now` the **timer**. The service stays `inactive (dead)` between runs.
- `WantedBy=timers.target` in `[Install]` lets `enable` arm the timer on every boot.
- `systemctl list-timers` shows NEXT, LAST and the service each timer ACTIVATES.

**From [Schedule Expressions](./course-02-schedule-expressions.md):**

- `OnCalendar=` takes `DayOfWeek Year-Month-Day Hour:Minute:Second`, with `*`, lists, ranges, steps and shortcuts such as `daily`.
- `systemd-analyze calendar '<expression>'` shows how systemd reads an expression and when it fires next.
- `OnBootSec=`, `OnUnitActiveSec=` and the rest count from an event, not from the wall clock.
- `Persistent=true` runs a missed job once after the next boot. `RandomizedDelaySec=` spreads start times.
- systemd treats `#` as a comment only at the start of a line.

**From [Converting A Cron Job To A Timer](./course-03-converting-cron-to-a-timer.md):**

- A timer gives a job journal logging, ordering, resource limits, catch-up and a status per run.
- Cron `MIN HOUR DOM MON DOW` becomes `OnCalendar=DOW *-MON-DOM HOUR:MIN`.
- Remove the cron line after converting, or the job runs twice.

**From [Operating Timers](./course-04-operating-timers.md):**

- Start the **service** to run the job now; starting the timer only arms it.
- `systemctl status`, `systemctl is-failed` and `journalctl -u <service>` show how the last runs went. `OnFailure=` reports failures.
- `systemctl disable --now` pauses a timer. `loginctl enable-linger <user>` keeps user timers running with nobody logged in.

## Your missions

You proved these skills in a graded mission, right after the part that taught the last of them:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [systemd Timers Lab](./labs/lab-01/README.md) | Operating Timers | built a twice-weekly timer with catch-up, and replaced a cron job with a six-hourly timer |

If you skipped it, go back to it now. It is short, and the exam asks for exactly these skills.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. You have <code>cleanup.timer</code> and <code>cleanup.service</code>. Which one do you enable, and why?</summary>

`cleanup.timer`. The timer holds the schedule and starts the service. Enabling the service would run it once at every boot instead of on schedule.
</details>

<details>
<summary>2. You wrote two new unit files and <code>systemctl enable</code> says "Unit … not found". What did you forget?</summary>

`sudo systemctl daemon-reload`, so systemd reads the new unit files.
</details>

<details>
<summary>3. How do you check that <code>OnCalendar=Sat,Sun 09:00</code> means what you think?</summary>

Run `systemd-analyze calendar 'Sat,Sun 09:00'` and read the normalized form and the next elapse time.
</details>

<details>
<summary>4. The machine was switched off at the time a daily timer should have fired. What makes the job run after the next boot?</summary>

`Persistent=true` in the `[Timer]` section. Without it, the missed run is skipped.
</details>

<details>
<summary>5. Convert the cron line <code>0 3 * * SUN /usr/local/sbin/weekly.sh</code> into an <code>OnCalendar=</code> value.</summary>

`OnCalendar=Sun *-*-* 03:00:00`, which you can also write as `Sun 03:00`.
</details>

<details>
<summary>6. You want to run a timer's job right now, to test it. What do you start?</summary>

The service, for example `sudo systemctl start archive.service`. Starting the timer only arms it.
</details>

<details>
<summary>7. You converted a cron job to a timer and now the script runs twice. Why?</summary>

The cron line is still in place. Neither cron nor systemd removes duplicates, so remove the cron entry.
</details>

<details>
<summary>8. A user's timer stops firing when they log out. How do you fix it?</summary>

Run `sudo loginctl enable-linger <user>`, so the user's systemd manager keeps running with nobody logged in.
</details>

## Clean up

Each mission runs a virtual machine on your computer. When you are done with this module, remove any mission that is still running.

First, see what is still running:

```sh
astrona list
```

If the mission is still there, remove it. The command takes its **name**, not its folder path:

```sh
astrona destroy ats-002-lab-023
```
