# Question

Solve this question on: `terminal`

The script `/usr/local/sbin/archive-logs.sh` archives logs. The `at` and `anacron` packages are installed, the `atd` service is running, and the user `ops-monitor` exists.

1. Queue **one** `at` job that runs `/usr/local/sbin/archive-logs.sh` at **03:00**. Use `sudo`, so the job belongs to `root`.
2. Add a job to `/etc/anacrontab` with the identifier `weekly-archive`. It runs `/usr/local/sbin/archive-logs.sh` every **7 days**, with a delay of **10 minutes**.
3. Refuse the user `ops-monitor` for `crontab` by listing the user in `/etc/cron.deny`. Do not create `/etc/cron.allow`.

The grader checks that `atq` shows a job at 03:00 whose content (`at -c`) calls the script, that `/etc/anacrontab` has a line with the fields `7`, `10`, `weekly-archive` and the script path and that `anacron -T` accepts the file, and that `/etc/cron.deny` lists `ops-monitor` while `/etc/cron.allow` does not exist.
<!-- curriculum-links -->

## Related lessons and assessment

Read [module-04](../../course.md).

The grader checks:

- Confirms an at job is queued for 03:00 that runs /usr/local/sbin/archive-logs.sh.
- Confirms /etc/anacrontab has the weekly-archive job and passes anacron -T.
- Confirms ops-monitor is listed in /etc/cron.deny and no cron.allow file exists.

Use the inspection commands in the solution to check your work. Submit when you have finished; submission ends this environment.
