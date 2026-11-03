# APT Package Groups & Bulk Operations Lab

Welcome to a bulk-cargo mission, astronaut. This training ship needs a build toolchain, and it carries a whole family of PHP 8.1 module packages that must not move during an upcoming upgrade.

Your job is to install the toolchain in one `apt install` transaction, find every `php8.1-*` package by naming pattern, and hold the whole family together in one checked step.

## Launching the Lab

Run this command to start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-050/module-05/labs/lab-01
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-055
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-050/module-05/labs/lab-01
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-055
```
