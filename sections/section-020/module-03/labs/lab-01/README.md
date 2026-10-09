# systemd Timers Lab

Welcome to an alarm clock mission, astronaut. This ship has two maintenance scripts, and one of them still runs from an old cron job.

Your job is to build a `.service` and `.timer` pair that runs a report every Monday and Thursday at 11:15 with catch-up after downtime, and to replace the old cron job with a timer that fires every six hours, without leaving the job running twice.

## Launching the Lab

Run this command to start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-020/module-03/labs/lab-01
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-023
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-020/module-03/labs/lab-01
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-023
```
