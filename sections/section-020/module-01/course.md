# Per-User Cron Job Scheduling

Astronaut, a ship that only works while you watch it is not ready for deep space. Some jobs must run at 22:00 every night, or every Monday morning, with nobody at the console. On Linux the `cron` daemon does this: it reads standing orders from the ship's duty roster and starts each one at its time.

A standing order can live in two kinds of place. It can sit in the shared, root-only roster (`/etc/crontab` and the files in `/etc/cron.d/`), or in one account's own crontab, which you edit with `crontab -e`. The two places use different line formats, and mixing them up makes a job fail without a word. This module teaches both formats and a safe order for moving a job from one place to the other.

## Learning objectives

After this module you can:

- Name the places `cron` reads, and say which of them only root may change and why.
- Tell a six-field system-wide cron line from a five-field per-user line, and turn one into the other.
- Read and write the five time fields, including lists, ranges, `*/N` steps and weekday or month names.
- Edit another account's crontab with `sudo crontab -u <user> -e`, and explain why editing its spool file by hand is unsafe.
- Move a job between the two places in an order that never leaves it unscheduled and never leaves it running twice.
- Check which jobs an account owns with `sudo crontab -u <user> -l`, instead of reading spool files.

## Before you start

Check that you have the knowledge and the tools this module expects.

### What you should already know

- **How to work in a shell.** You can type commands, use `sudo`, and edit a file in a terminal editor such as `nano` or `vim`.
- **What a background service is.** A daemon is a program that keeps running in the background and does its work without anyone typing commands.

You need no earlier experience with cron.

### What you need

- A terminal on an Ubuntu 24.04 machine with `cron` installed. Any such machine works for the examples in the parts.
- Or a running lab machine: the mission in this module gives you the exact commands to start it and open a terminal on it.

## How this module is laid out

1. [Where A Cron Job Lives](./course-01-where-a-cron-job-lives.md): the places `cron` reads, six-field system-wide lines and five-field per-user lines, the time field rules, and the silent failure when the two formats are mixed.
2. [Migrating A Job Safely](./course-02-migrating-a-job-safely.md): what `crontab -u <user> -e` does underneath, why you never edit the spool file by hand, and the order recreate, check, delete, check again.
   - Mission: [Per-User Cron Job Scheduling Lab](./labs/lab-01/README.md)
3. [Wrap-Up: Mission Debrief](./course-03-wrap-up.md)

## Why this matters

A scheduled job fails at night, when nobody is watching. If it runs under the wrong account, or runs twice, or does not run at all, you often find out days later from damaged data. The exam asks you to move jobs between the shared roster and a user's crontab, so you need to get the format and the order right the first time.
