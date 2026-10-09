# APT Basic Package Operations Lab

Welcome to a maintenance mission, astronaut. This training ship needs its routine package care: a fresh catalogue, its upgrades, one new package, and one old package retired for good.

Your job is to run that loop in order, install `fail2ban`, purge `ftp` together with its configuration file, and clean up any orphaned dependencies.

## Launching the Lab

Run this command to start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-050/module-03/labs/lab-01
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-053
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-050/module-03/labs/lab-01
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-053
```
