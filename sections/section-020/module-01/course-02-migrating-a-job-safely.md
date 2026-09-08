# Part 2 — Migrating a job safely

> Prerequisite: [Part 1 — Where a cron job lives, and the format that follows](./course-01-where-a-cron-job-lives.md). Next: [Section 020 quiz](../quiz.md).

Moving a job from a system-wide file into a per-user crontab is three steps, in order: recreate it correctly, verify the copy, then delete the original. Skip the last step and the job runs twice. This part is the `crontab` command's mechanism, why hand-editing the spool is unsafe, and the one verification that counts.

## `crontab -u` edits another account's spool

Plain `crontab -e` as root edits **root's own** crontab — almost never what you want when relocating a service account's job. Name the target account:

```bash
# shell: host, root
sudo crontab -u asset-manager -e
```

`-u asset-manager` makes `crontab` operate on `/var/spool/cron/crontabs/asset-manager` instead of root's spool. What `crontab -e` does underneath, and why it is the only safe way in:

```
  crontab -u asset-manager -e
        │
        ├─ copy the current spool file to a temp file
        ├─ open the temp file in $EDITOR (or $VISUAL)
        │
   on save:
        ├─ parse every line — reject the file on a syntax error, keep the old one
        ├─ install it as /var/spool/cron/crontabs/asset-manager
        │     owner = asset-manager, group = crontab, mode 0600
        └─ touch the spool dir so the daemon re-reads on its next tick
```

Hand-editing the spool file with a text editor skips **all** of that: no syntax check, and an editor that writes the file as root:root mode 0644 leaves cron refusing to trust it (silently — the jobs just never run).

`crontab -u asset-manager -l` lists that account's crontab; `crontab -u asset-manager -r` removes it entirely (no confirmation — be careful).

## Find the original before you touch it

The job could be a standalone drop-in (`/etc/cron.d/asset-cleanup`) or a single line inside the shared `/etc/crontab`. Locate it exactly:

```bash
# shell: host, root
sudo grep -rn 'nightly-sync.sh' /etc/crontab /etc/cron.d/
```

```text
/etc/cron.d/asset-cleanup:3:30 20 * * * asset-manager /home/asset-manager/nightly-sync.sh
```

A hit inside `/etc/crontab` or a shared drop-in means you edit that file to remove one line. A hit that *is* its own file under `/etc/cron.d/` means you delete the file.

## Recreate, verify, then delete — in that order

`cron` has **no deduplication**. If the same command is scheduled in two places it runs twice, independently, at the same wall-clock second. On a script that writes shared data that is a race waiting to corrupt something.

So the order is strict:

1. `sudo crontab -u asset-manager -e` — add the job **with the username field stripped** (Part 1).
2. `sudo crontab -u asset-manager -l` — confirm it is there, exactly as intended.
3. Only now remove the source: `sudo rm /etc/cron.d/asset-cleanup` (or delete the one line from `/etc/crontab`).
4. `sudo grep -rn 'nightly-sync.sh' /etc/crontab /etc/cron.d/` again — expect no output.

Deleting first and then discovering the per-user copy had a typo means the job simply does not run until you notice.

## The only verification that matters

```bash
sudo crontab -u asset-manager -l
```

```text
30 20 * * * /home/asset-manager/nightly-sync.sh
15 11 * * MON,THU bash /home/asset-manager/clean.sh
```

This is what `cron` will actually execute for that account. If a job is not listed here under the right user, it does not matter what you typed into an editor — it is not owned by that account. Trust this output over reading raw spool files.

> [!WARNING]
> - **Deleting the system-wide source before verifying the per-user copy** → a gap where the job does not run at all.
> - **Leaving both copies in place** → the command runs twice per fire; on shared data that is a corruption race.
> - **`crontab -e` as root when you meant a service account** → you just edited root's crontab. Always `-u <user>`.
> - **`crontab -r` fat-fingered** → wipes the whole crontab, no prompt. `-l` first, keep a copy.

> *Migrate in the order recreate → `crontab -u <user> -l` to verify → delete the original → re-grep to confirm; cron never deduplicates, and `crontab -u <user> -l` is the only source of truth for what will run.*

## Reference

- `man 1 crontab` — `-u`, `-e`, `-l`, `-r`; the temp-file-and-validate install flow.
- `man 5 crontab` — the syntax `crontab -e` validates on save.
- `man 8 cron` — file-trust rules: why a hand-written spool file with the wrong owner or mode is ignored.
