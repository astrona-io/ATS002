# Per-User Cron Job Scheduling Lab

Welcome to a scheduling mission, astronaut. A job that belongs to the service account `asset-manager` still sits on the ship's shared, root-only duty roster.

Your job is to move it into `asset-manager`'s own crontab, add a new job that runs twice a week, and remove the original so the job never runs twice.

## Launching the Lab

Run this command to start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-020/module-01/labs/lab-01
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-021
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-020/module-01/labs/lab-01
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-021
```
