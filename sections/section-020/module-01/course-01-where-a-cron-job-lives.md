# Part 1 — Where a cron job lives, and the format that follows

> Prerequisite: [module landing page](./course.md). Next: [Part 2 — Migrating a job safely](./course-02-migrating-a-job-safely.md).

A cron job can live in one of two kinds of place, and the *place* dictates the *line format* — specifically whether the line carries a username. Get that mapping wrong and the job fails silently at 8:30pm with nobody watching. This part is the two locations, the field grammar, and how `cron` actually finds and runs them.

## Two locations, read by the same daemon

The `cron` daemon (`cron` on Debian/Ubuntu, `crond` on RHEL) wakes once a minute and scans a fixed set of sources:

```
  cron daemon (once per minute)
    ├── /var/spool/cron/crontabs/<user>   ← PER-USER crontabs (Debian path)
    │                                        one file per account, mode 600, owned by that user
    ├── /etc/crontab                       ← SYSTEM-WIDE, single file
    ├── /etc/cron.d/*                      ← SYSTEM-WIDE drop-ins, one concern per file
    └── /etc/cron.{hourly,daily,weekly,monthly}/   ← run-parts scripts, no cron line at all
```

The per-user spool is where `crontab -e` writes. `/etc/crontab` and `/etc/cron.d/` are the shared area — editable only by root, because of what their line format grants.

As an analogy (flagged): the shared area is an office mail room — every memo must carry a name ("deliver to: Alice") because the room belongs to no one. A per-user crontab is Alice's own mailbox — the container already says whose it is, so the memo needs no name. Where it breaks down: a real mailbox is physically Alice's; a spool file is just a file the daemon trusts *because* of its path, owner, and mode — tamper with those and cron ignores it.

## The line format — six fields vs five

A **system-wide** line (`/etc/crontab`, `/etc/cron.d/*`) has **six** fields before the command:

```text
30 20 * * *  asset-manager  /home/asset-manager/nightly-sync.sh
│  │  │ │ │   └─ USER the command runs as (mandatory here)
│  │  │ │ └───── day of week   (0-7, 0 and 7 = Sunday; or SUN..SAT)
│  │  │ └─────── month         (1-12 or JAN..DEC)
│  │  └───────── day of month  (1-31)
│  └──────────── hour          (0-23, 24-hour clock — no am/pm)
└─────────────── minute        (0-59)
```

That username field is the whole reason these files are root-only: a line in `/etc/cron.d/` can run any command **as any account on the box**.

A **per-user** line (`crontab -e`, the spool file) drops the username — five fields, then the command:

```text
30 20 * * *  /home/asset-manager/nightly-sync.sh
```

Ownership is implicit: the daemon runs it as whoever owns the spool file.

**The silent-failure trap:** paste a six-field system line into a five-field per-user crontab and cron does not error. It reads `asset-manager` as the first word of the command and tries to `exec` a program literally named `asset-manager`. That fails, quietly, every time the schedule fires.

## Field syntax that shows up under pressure

Each of the five time fields accepts more than a bare number or `*`:

| Form | Example | Means |
|---|---|---|
| value | `15` | exactly 15 |
| list | `MON,THU` or `1,4` | any of these |
| range | `1-5` | 1 through 5 inclusive |
| step | `*/10` | every 10 (0,10,20,…) |
| range+step | `0-30/5` in minutes | 0,5,10,…,30 |
| names | `MON`, `JAN` | case-insensitive, first 3 letters; **lists/ranges of names work, not all combos on every cron** |

"11:15am every Monday and Thursday":

```cron
15 11 * * MON,THU  bash /home/asset-manager/clean.sh
```

`15` minute, `11` hour (24h), day-of-month and month `*`, day-of-week the list `MON,THU`. Numeric weekdays (`0`–`7`) also work, but the named form removes any "is Monday 0 or 1 here" doubt.

A crontab file can also set environment before the jobs: `PATH=`, `SHELL=`, `MAILTO=` (empty `MAILTO=""` silences job output mail). And `@`-shortcuts replace the five fields: `@reboot`, `@daily`, `@hourly`, `@weekly`, `@monthly`.

> [!WARNING]
> - **Username field pasted into a per-user crontab** → cron treats it as the command name and the job fails silently. Strip it.
> - **Editing `/var/spool/cron/crontabs/<user>` by hand** → wrong mode/owner, and cron distrusts the file. Always go through `crontab` (Part 2).
> - **Numeric weekday confusion** → both `0` and `7` are Sunday; use `SUN`–`SAT` names to sidestep it.
> - **`*/N` off a non-zero base** → `*/10` on minutes fires at :00,:10,…; it is not "10 minutes from now". Use an explicit list if you need a phase offset.

> *System-wide cron lines (`/etc/crontab`, `/etc/cron.d/*`, root-only) carry a mandatory username as their 6th field; per-user crontab lines have 5 fields and infer the user from the spool file's owner — mixing the two makes the job fail silently.*

## Reference

- `man 5 crontab` — the field grammar, `@`-shortcuts, environment lines, name forms.
- `man 8 cron` / `man 8 crond` — how the daemon scans the spool and `/etc/cron.d`, and the file-trust rules (owner, mode).
- `man 8 run-parts` — how `/etc/cron.{daily,hourly,…}/` scripts are executed (they are not cron lines).
