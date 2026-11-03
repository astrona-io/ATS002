# Overview: Per-User Cron Job Scheduling Playground

This is a **playground**, not a lab. The training ship starts clean, runs its preparation script once, and then waits for you. There is no task, no `astrona submit` and no pass or fail. Explore, break things, run `astrona destroy`, and start over.

## What's in the box

Your playground is one duty roster, ready for standing orders:

- A single Ubuntu 24.04 `qemu` virtual machine. Reach it with `astrona ssh astro-cron-schedule-bay`.
- The `cron` daemon, enabled and running.
- The service account `archivist`, with `/home/archivist/archive-logs.sh`. The system-wide file `/etc/cron.d/log-archive` runs it every night at 22:00 (`0 22 * * * archivist /home/archivist/archive-logs.sh`).
- The service account `asset-manager`, with `/home/asset-manager/nightly-sync.sh` and `/home/asset-manager/clean.sh`. The system-wide file `/etc/cron.d/asset-cleanup` runs `nightly-sync.sh` every day at 20:30.
- No per-user crontab exists yet for either account.

## Things to try

- Run `sudo grep -rn 'archive-logs.sh' /etc/crontab /etc/cron.d/` and read the six-field line it finds.
- Open the account's crontab with `sudo crontab -u archivist -e` and add the five-field form of the same job. Check it with `sudo crontab -u archivist -l`.
- Delete `/etc/cron.d/log-archive`, then search again with `grep -rn` and expect no output.
- Paste the six-field line into a per-user crontab on purpose and see why the job cannot run (the username becomes the first word of the command).
- Try the field forms: a list (`MON,THU`), a range (`1-5`) and a step (`*/15`).

## When you're done

```sh
astrona destroy cron-schedule-bay
```

`astrona destroy` takes the playground's name, not the folder path. The terminal command uses `astro-cron-schedule-bay`; the `astro-` prefix is optional there. The name for `astrona destroy` is `cron-schedule-bay`.
