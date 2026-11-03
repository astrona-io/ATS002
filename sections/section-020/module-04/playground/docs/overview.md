# Overview: One-Shot And Missed Jobs Playground

This is a **playground**, not a lab. The training ship starts clean, runs its preparation script once, and then waits for you. There is no task, no `astrona submit` and no pass or fail. Explore, break things, run `astrona destroy`, and start over.

## What's in the box

Your playground is one ship with the scheduling tools ready:

- A single Ubuntu 24.04 `qemu` virtual machine. Reach it with `astrona ssh astro-at-anacron-bay`.
- The `at`, `anacron` and `cron` packages, all installed. The `atd` service is running.
- The user `ops-monitor`, a normal account with no jobs.
- The script `/usr/local/sbin/archive-logs.sh`. It adds one line with the time to `/var/log/archive-logs.log`.
- No `/etc/cron.allow` and no `/etc/cron.deny` file.

## Things to try

- Queue the script for two minutes from now: `echo /usr/local/sbin/archive-logs.sh | at now + 2 minutes`. Then run `atq`, `at -c <ID>` and, after the time has passed, `cat /var/log/archive-logs.log`.
- Remove a waiting job with `atrm <ID>`.
- Queue a job with `batch` and watch `atq`.
- Run `cat /etc/anacrontab` and `sudo ls -l /var/spool/anacron/`.
- Add a job line to `/etc/anacrontab` and test it with `sudo anacron -T`.
- Put `ops-monitor` in `/etc/cron.deny` and run `sudo -u ops-monitor crontab -l`.
- Create `/etc/cron.allow` with only `ops-monitor` in it and see who may use `crontab` now.

## When you're done

```sh
astrona destroy at-anacron-bay
```

`astrona destroy` takes the playground's name, not the folder path. The terminal command uses `astro-at-anacron-bay`; the `astro-` prefix is optional there. The name for `astrona destroy` is `at-anacron-bay`.
