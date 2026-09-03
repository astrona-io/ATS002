# Solution Walkthrough

Follow these steps to migrate the job and add the new one without leaving a duplicate-execution bug behind.

---

## Step 1: Locate the existing system-wide 8:30pm job

```bash
sudo grep -rn "30 20" /etc/crontab /etc/cron.d/ 2>/dev/null
```

8:30pm in 24-hour cron time is `30 20` (minute 30, hour 20). System-wide cron sources are `/etc/crontab` itself and any file dropped under `/etc/cron.d/`. This turns up:

```
/etc/cron.d/asset-cleanup:30 20 * * * asset-manager /home/asset-manager/nightly-sync.sh
```

The sixth field, `asset-manager`, is the username field unique to system-wide cron syntax — it tells cron which account to run the command as, even though the file itself is controlled by root.

## Step 2: Confirm the exact command before migrating it

```bash
sudo cat /etc/cron.d/asset-cleanup
```

Copy the exact command (`/home/asset-manager/nightly-sync.sh`) so the migrated job does precisely what the old one did.

## Step 3: Create the per-user crontab entry for asset-manager

```bash
sudo crontab -u asset-manager -e
```

Running plain `crontab -e` as root would instead edit *root's own* crontab — the wrong owner entirely. `-u asset-manager` tells `crontab` to operate on the spool file for that specific user. In the editor, add:

```cron
30 20 * * * /home/asset-manager/nightly-sync.sh
```

Notice there is **no username field** — in a per-user crontab, ownership is implicit from whose crontab file it is. Leaving the username field in would be interpreted as part of the command itself and break the job.

## Step 4: Add the new twice-weekly cleanup job in the same crontab

While still in `crontab -u asset-manager -e` (or by reopening it), add a second line:

```cron
15 11 * * MON,THU bash /home/asset-manager/clean.sh
```

Field breakdown: minute `15`, hour `11` (11:15am, 24-hour clock), day-of-month `*`, month `*`, day-of-week `MON,THU`. Named days are safer than numbers under exam pressure — you don't have to remember whether a given cron flavor treats `0` or `7` as Sunday. Save and exit; `crontab` validates syntax on save and refuses to install a malformed file.

## Step 5: Remove the original system-wide entry

```bash
sudo rm /etc/cron.d/asset-cleanup
```

This step is not optional. Skipping it means the exact same command fires from *two* independent schedules at 8:30pm every day — on a data script, that means double-processing or race conditions on the same files.

## Step 6: Verify

```bash
sudo crontab -u asset-manager -l
# 30 20 * * * /home/asset-manager/nightly-sync.sh
# 15 11 * * MON,THU bash /home/asset-manager/clean.sh

sudo grep -rn "nightly-sync.sh" /etc/crontab /etc/cron.d/ 2>/dev/null
# (no output expected)
```

`crontab -u asset-manager -l` is the only verification that actually matters — it's exactly what cron itself will execute. If a job doesn't show up there under the right user, it isn't owned by that account no matter what you typed into an editor.

---

## Command Summary

```bash
sudo grep -rn "30 20" /etc/crontab /etc/cron.d/
sudo cat /etc/cron.d/asset-cleanup
sudo crontab -u asset-manager -e
# add:
# 30 20 * * * /home/asset-manager/nightly-sync.sh
# 15 11 * * MON,THU bash /home/asset-manager/clean.sh
sudo rm /etc/cron.d/asset-cleanup
sudo crontab -u asset-manager -l
```

Once verified, run the local validation suite to pass the lab!
