# Per-User Cron Job Scheduling

Think of a shared office mail room. A memo dropped into the general mail room has to carry a name on it — "Deliver to: Alice" — because the mail room itself doesn't belong to anyone in particular. But a memo you drop directly into Alice's own personal mailbox doesn't need her name written on it at all. The mailbox itself already tells you whose it is.

That is exactly the difference between system-wide cron and a per-user crontab. `/etc/crontab` and the drop-in files under `/etc/cron.d/` are the shared mail room — every line has to explicitly state which user account the command should run as. A per-user crontab, edited with `crontab -e`, is somebody's personal mailbox — ownership is implicit in whose file it is, so the line only needs the schedule and the command.

## Two Places a Job Can Live

A line in `/etc/crontab` or `/etc/cron.d/*` has six fields:

```text
30 20 * * * asset-manager /home/asset-manager/nightly-sync.sh
```

Five time fields, then a mandatory **username field**, then the command. That username field is the whole reason system-wide cron files can be edited only by root (or root-owned drop-ins) — it's granting the file the power to run arbitrary commands as any account on the box.

A per-user crontab line drops that field entirely:

```text
30 20 * * * /home/asset-manager/nightly-sync.sh
```

Five fields and a command, nothing else. If you paste a system-wide line straight into a per-user crontab without stripping the username field, cron doesn't error out helpfully — it just treats `asset-manager` as the first word of the command and tries to execute a program by that name, which fails silently at 8:30pm with nobody watching.

---

## Editing Someone Else's Mailbox

Plain `crontab -e`, run as root, edits *root's own* crontab. That is almost never what you want when you're migrating a job that belongs to a service account. To touch another user's crontab, you name it explicitly:

```bash
sudo crontab -u asset-manager -e
```

The `-u asset-manager` flag tells `crontab` to operate on the spool file belonging to that account — on Debian/Ubuntu that's `/var/spool/cron/crontabs/asset-manager` — rather than on root's. This requires privilege, which is exactly why the command is prefixed with `sudo`. Never hand-edit that spool file directly with a text editor; going around `crontab` skips its syntax validation and can leave behind a file with permissions cron refuses to trust.

## Reading the Time Fields

Cron's five time fields are, in order: minute, hour, day-of-month, month, day-of-week. A schedule for "11:15am every Monday and Thursday" reads as:

```cron
15 11 * * MON,THU bash /home/asset-manager/clean.sh
```

`15` is the minute, `11` is the hour on a 24-hour clock (so there's no am/pm ambiguity to get wrong), the day-of-month and month fields are `*` for "any," and the day-of-week field takes a comma-separated list, `MON,THU`. Cron also accepts numeric weekdays (`0`–`7`, where both `0` and `7` mean Sunday), but under exam pressure the named form is safer — you don't have to remember whether a particular cron implementation counts Monday as `1` or as `0`.

---

## Migrating Without Duplicating

Moving a job from a system-wide file into a per-user crontab is not complete until you delete the original. Cron has no concept of deduplication. If the same command is scheduled in two places, it runs twice, independently, at the same wall-clock time — and on a script that touches shared data, that's a race condition waiting to corrupt something.

```bash
sudo grep -rn "nightly-sync.sh" /etc/crontab /etc/cron.d/
sudo rm /etc/cron.d/asset-cleanup
```

Grep first to confirm exactly where the job lives — it could be its own drop-in file under `/etc/cron.d/`, or a single line buried inside the shared `/etc/crontab`. Only after you've verified the per-user copy is correct should you remove the old source.

## Proving Ownership

The only verification that actually matters is what cron itself will execute:

```bash
sudo crontab -u asset-manager -l
```

```text
30 20 * * * /home/asset-manager/nightly-sync.sh
15 11 * * MON,THU bash /home/asset-manager/clean.sh
```

If a job doesn't show up here under the right user, it doesn't matter what you think you typed into an editor — it isn't owned by that account. Trust this output over reading raw spool files by hand.

---

## Self-Check and Verification

To prove your cron migration is correct:

1. Locate the original system-wide job by grepping `/etc/crontab` and `/etc/cron.d/` for its time pattern.
2. Recreate it as a per-user crontab line using `sudo crontab -u <user> -e`, with the username field stripped out.
3. Add a second job to the same crontab using a comma-separated day-of-week list.
4. Delete the original system-wide file or line, and re-grep to confirm no trace of it remains.
5. Run `sudo crontab -u <user> -l` and confirm both jobs appear, exactly as intended, under the correct owner.
