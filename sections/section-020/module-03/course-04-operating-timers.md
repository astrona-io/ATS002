# Operating Timers

Astronaut, an alarm clock is only useful if you know it is set, can test it, and hear about it when the job fails. This part covers the everyday commands for a timer that already exists: checking it, running its job now, reading the results in the ship's log, and pausing it. It ends with timers that survive a reboot and timers that belong to one user.

The examples use a pair called `archive.timer` and `archive.service`, where the service runs `/usr/local/sbin/archive.sh`.

## Everyday commands

Each command below answers one question about the timer or its last run.

### Check, run, read and pause

```bash
# is it armed, and pointing at the right service?
systemctl list-timers archive.timer

# force a run now, out of schedule (for example to test the service)
sudo systemctl start archive.service

# did the last run succeed?
systemctl status archive.service
systemctl is-failed archive.service           # "failed" if the last run failed

# the output of past runs
journalctl -u archive.service --since today

# pause the schedule without deleting anything
sudo systemctl disable --now archive.timer
```

`systemctl is-failed` prints the unit's state. After a clean run, a oneshot service prints `inactive`; after a failed run it prints `failed`.

To test the job, start the **service**. Starting the timer only arms the alarm clock; it does not run the job. `journalctl -u` reads the ship's log for one unit, so you see everything the script printed on each run.

### Hearing about failures

A scheduled job that fails does not announce itself. Check `systemctl list-timers` now and then (the LAST column should move forward) and read `journalctl -u <service>`. Or add an `OnFailure=` line to the service, which tells systemd to start another unit whenever this one fails:

```ini
[Unit]
OnFailure=notify-admin@%n.service
```

`%n` is replaced by the full name of the failed unit, so one `notify-admin@.service` template can report on many jobs.

## Timers that survive a reboot, and user timers

A timer can belong to the whole ship or to one crew member. Both need the right setup to keep firing.

### Surviving a reboot

The `.timer` needs `[Install]` with `WantedBy=timers.target`, and you must run `systemctl enable` on it. Without both, the timer only runs until the next boot.

### User timers

**User timers** (`systemctl --user`) live in `~/.config/systemd/user/` and run under that user's own systemd manager. By default that manager only runs while the user is logged in. `sudo loginctl enable-linger <user>` keeps the user's manager, and so their timers, running with nobody logged in. This is the systemd version of a per-user crontab.

## Common pitfalls

> [!WARNING]
> - **`systemctl start archive.timer` when you meant to test the job.** That only arms the timer. To run the job now, use `systemctl start archive.service`.
> - **A user timer that stops when you log out.** Run `loginctl enable-linger <user>` so it keeps firing.
> - **Thinking a failed run is visible.** It is silent. Watch `list-timers` and `journalctl -u <service>`, or add `OnFailure=`.
> - **A timer that is started but not enabled.** It works until the next reboot and then never fires again. Use `enable --now`.

## Your mission: systemd Timers Lab

You can now write a `.service` and `.timer` pair, test its schedule, convert a cron job, and check the result. The mission asks you to build a new twice-weekly timer with catch-up, and to replace an existing cron job with a timer that fires every six hours.

The mission runs on its own training ship. Start it and open a terminal on it:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-020/module-03/labs/lab-01
astrona ssh ats-002-lab-023
```

Read the task in [`question.md`](./labs/lab-01/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-020/module-03/labs/lab-01
```

When the mission is done, remove it:

```sh
astrona destroy ats-002-lab-023
```
