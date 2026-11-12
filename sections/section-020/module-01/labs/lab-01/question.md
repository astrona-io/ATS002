# Question

Solve this question on: `terminal`

Astronaut, on this server (`data-001`) the user `asset-manager` runs the timed jobs that work on existing data. Right now one system-wide cron job runs every day at 8:30 pm (20:30) as `asset-manager`. Mission control wants all of `asset-manager`'s jobs in that account's own crontab.

1. Move that system-wide cron job into `asset-manager`'s own crontab, with the same schedule and the same command. It must appear when you list `asset-manager`'s crontab (`crontab -l` as that user, or `sudo crontab -u asset-manager -l`).
2. Add a new cron job to `asset-manager`'s crontab that runs `bash /home/asset-manager/clean.sh` every week on Monday and Thursday at 11:15 am.
3. Remove the original system-wide cron job, so the job no longer runs from two places. No line that runs `nightly-sync.sh` may remain in `/etc/crontab` or in any file under `/etc/cron.d/`.

The grader reads `asset-manager`'s crontab and searches `/etc/crontab` and `/etc/cron.d/`.
<!-- curriculum-links -->

## Related lessons and assessment

Read [module-01](../../course.md).

The grader checks:

- Confirms asset-manager's per-user crontab contains both the converted 8:30pm nightly-sync.sh job and the new Mon/Thu 11:15am clean.sh job.
- Confirms the original system-wide nightly-sync.sh entry no longer exists in /etc/crontab or /etc/cron.d/.

Use the inspection commands in the solution to check your work. Submit when you have finished; submission ends this environment.
