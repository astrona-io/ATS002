# One-Shot And Missed Jobs Lab

Welcome to a duty roster mission, astronaut. This training ship has a log-archiving script waiting at `/usr/local/sbin/archive-logs.sh`, and a user named `ops-monitor` who must not write on the roster.

Your job is to queue the script once for 03:00, make anacron run it weekly even when the ship was off, and refuse `ops-monitor` for `crontab`.

## Launching the Lab

Run this command to start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-020/module-04/labs/lab-01
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-024
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-020/module-04/labs/lab-01
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-024
```
