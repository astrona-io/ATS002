# Overview: systemd Timers Playground

This is a **playground**, not a lab. The training ship starts clean, runs its preparation script once, and then waits for you. There is no task, no `astrona submit` and no pass or fail. Explore, break things, run `astrona destroy`, and start over.

## What's in the box

Your playground is one duty officer's desk, with the scripts for the alarm clocks already on board:

- A single Ubuntu 24.04 `qemu` virtual machine. Reach it with `astrona ssh astro-systemd-timer-bay`.
- `systemd` with its own timers, so `systemctl list-timers` already shows a few.
- Four scripts in `/usr/local/sbin`: `backup.sh`, `archive.sh`, `report.sh` and `dbclean.sh`. Each one appends one line with the time to a log file under `/var/log/maint`.
- One old cron job, `/etc/cron.d/dbclean`, which runs `dbclean.sh` every 6 hours. It is the job you convert to a timer.
- No timer or service units of your own exist yet.

## Things to try

- Save the `nightly-backup.service` and `nightly-backup.timer` pair from the module, run `sudo systemctl daemon-reload`, then `sudo systemctl enable --now nightly-backup.timer` and read `systemctl list-timers`.
- Test expressions with `systemd-analyze calendar 'Mon,Thu 11:15'` and `--iterations=5`.
- Run the service by hand with `sudo systemctl start archive.service` and read the result with `journalctl -u archive.service` and `cat /var/log/maint/archive.log`.
- Convert `/etc/cron.d/dbclean` into a `dbclean.service` and `dbclean.timer` pair, then delete the cron file and search again with `grep -rn 'dbclean.sh' /etc/crontab /etc/cron.d/`.
- Pause a timer with `sudo systemctl disable --now archive.timer` and check that the service file is still there.

## When you're done

```sh
astrona destroy systemd-timer-bay
```

`astrona destroy` takes the playground's name, not the folder path. The terminal command uses `astro-systemd-timer-bay`; the `astro-` prefix is optional there. The name for `astrona destroy` is `systemd-timer-bay`.
