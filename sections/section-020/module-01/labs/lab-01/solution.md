# Solution Walkthrough

Follow these steps to move the job and add the new one without leaving a job that runs twice. The shared, root-only roster is `/etc/crontab` plus the files in `/etc/cron.d/`. The account's own crontab is the one `crontab -u asset-manager -e` edits.

---

## Step 1: Find the system-wide 8:30 pm job

```bash
sudo grep -rn "30 20" /etc/crontab /etc/cron.d/ 2>/dev/null
```

8:30 pm on the 24-hour clock that cron uses is `30 20` (minute 30, hour 20). The system-wide cron sources are `/etc/crontab` itself and any file under `/etc/cron.d/`. The search turns up:

```
/etc/cron.d/asset-cleanup:30 20 * * * asset-manager /home/asset-manager/nightly-sync.sh
```

Because of `-n`, `grep` also prints the line number between the file name and the line (here `:1:`). The output above leaves it out.

The sixth field, `asset-manager`, is the username field that only system-wide cron lines have. It tells the `cron` daemon which account runs the command, even though root owns the file.

## Step 2: Read the exact command before you move it

```bash
sudo cat /etc/cron.d/asset-cleanup
```

Note the exact command, `/home/asset-manager/nightly-sync.sh`, so the moved job does exactly what the old one did.

## Step 3: Create the per-user crontab entry for asset-manager

```bash
sudo crontab -u asset-manager -e
```

Plain `crontab -e` as root would edit root's own crontab, which is the wrong owner. `-u asset-manager` tells `crontab` to work on that account's spool file. In the editor, add:

```cron
30 20 * * * /home/asset-manager/nightly-sync.sh
```

There is **no username field**. In a per-user crontab the owner is implied by whose crontab it is. If you kept `asset-manager` in the line, cron would read it as the command and the job would fail.

## Step 4: Add the twice-weekly cleanup job in the same crontab

While you are still in `crontab -u asset-manager -e` (or after opening it again), add a second line:

```cron
15 11 * * MON,THU bash /home/asset-manager/clean.sh
```

The fields are: minute `15`, hour `11` (11:15 am on the 24-hour clock), day of month `*`, month `*`, day of week `MON,THU`. Names are safer than numbers under exam pressure, because you do not have to remember whether this cron counts Sunday as `0` or `7`. Save and exit. `crontab` checks the syntax when you save and refuses to install a broken file.

## Step 5: Remove the original system-wide entry

```bash
sudo rm /etc/cron.d/asset-cleanup
```

This step is required. Without it, the same command runs from *two* schedules at 8:30 pm every day. On a data script, that means the data is processed twice, or two copies change the same files at the same time.

## Step 6: Check the result

```bash
sudo crontab -u asset-manager -l
# 30 20 * * * /home/asset-manager/nightly-sync.sh
# 15 11 * * MON,THU bash /home/asset-manager/clean.sh

sudo grep -rn "nightly-sync.sh" /etc/crontab /etc/cron.d/ 2>/dev/null
# (no output expected)
```

`crontab -u asset-manager -l` is the check that matters: it shows exactly what the `cron` daemon will run for that account. If a job does not show up there, it does not belong to that account, whatever you typed into an editor. The empty `grep` result proves that no system-wide copy is left.

When both checks look right, send the lab for grading:

```sh
astrona submit -c sections/section-020/module-01/labs/lab-01
```

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
