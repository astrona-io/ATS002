# One-Shot And Missed Jobs: at, batch And anacron

Astronaut, a standing order on the duty roster repeats every day. Sometimes you need something different: one order, once, at a set time. Sometimes a standing order was missed because the ship was switched off. This module teaches you the tools for both cases, and how to control who may write on the roster.

You work with `at`, `atq`, `atrm`, `batch`, `anacron` and the files `cron.allow` and `cron.deny`. Each has a small trap that costs time on the exam, so every part gives you something real to run.

## Learning objectives

After this module you can:

- Queue a one-time job with `at`, using times such as `03:00`, `now + 5 minutes` and `tomorrow`.
- List, read and remove queued jobs with `atq`, `at -c` and `atrm`.
- Explain what `batch` does and when it runs a job.
- Explain what `atd` does, and control access to `at` with `/etc/at.allow` and `/etc/at.deny`.
- Read and write the four fields of an `/etc/anacrontab` line.
- Explain where `anacron` keeps its timestamps and why it catches up on missed jobs.
- Allow or refuse users for `crontab` with `/etc/cron.allow` and `/etc/cron.deny`.

## Before you start

Check that you have the knowledge and the tools this module expects.

### What you should already know

- **How to work in a shell.** You can type commands and use `sudo`.
- **What a cron job is.** It is a standing order that repeats on a schedule. You do not need to write one for this module.

### What is in your playground

Your playground is one Ubuntu 24.04 training ship. The `at` and `anacron` packages are installed, the `atd` service is running, and a user named `ops-monitor` exists. A small script, `/usr/local/sbin/archive-logs.sh`, is ready to schedule. It adds one line with the time to `/var/log/archive-logs.log`.

Start the playground, then open a terminal on it with `astrona ssh astro-at-anacron-bay`. When you are finished, remove it with `astrona destroy at-anacron-bay`.

<!-- astrona:playground -->

Every command block says which rights it expects, so you can also follow the text on any Ubuntu 24.04 machine.

## How this module is laid out

1. [One-Shot Jobs With at](./course-01-one-shot-jobs-with-at.md): `at`, `atq`, `at -c`, `atrm`, time words, `batch`, the `atd` service and the access files.
2. [anacron And Cron Access Control](./course-02-anacron-and-cron-access-control.md): `/etc/anacrontab`, the timestamps, `run-parts`, `cron.allow` and `cron.deny`.
   - Mission: [One-Shot And Missed Jobs Lab](./labs/lab-01/question.md)
3. [Wrap-Up: Mission Debrief](./course-03-wrap-up.md)

## Why this matters

A repeating job does not fit every task. The exam asks you to schedule one job for a set time, to make a job run even when the machine was off, and to keep a user away from the roster. Each task leaves a file or a queue entry that you can check.

<!-- curriculum-practice -->
## Practice and assessment

- [One-Shot And Missed Jobs Lab](labs/lab-01/question.md): Queue a one-time job for a set time with at and check it with atq and at -c; Add a job to /etc/anacrontab with the right four fields and test the file; Refuse a user for crontab with /etc/cron.deny.
- [Scheduled Container Recovery Capstone Lab](../capstone/labs/lab-01/question.md): Remove a container that holds a host port and start its replacement with limits; Schedule a per-user watchdog script that restarts the container when it stops.
