# Question

Solve this question on: `terminal`

On this server (`data-001`), user `asset-manager` is responsible for timed operations on existing data. There is currently one system-wide cronjob configured that runs every day at 8:30pm, executed as `asset-manager`.

1. Convert that system-wide cronjob into one owned and executed by `asset-manager` directly — it should appear when you run `crontab -l` as that user.
2. Create a new cronjob, also owned and executed by `asset-manager`, that runs `bash /home/asset-manager/clean.sh` every week on Monday and Thursday at 11:15am.
3. Remove the original system-wide cronjob, so the job no longer fires from two places at once.
