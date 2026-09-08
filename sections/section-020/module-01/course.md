# Per-User Cron Job Scheduling

A scheduled job can live in the shared, root-only cron area (`/etc/crontab`, `/etc/cron.d/*`) or in an individual account's own crontab (`crontab -e`). The two use different line formats — the shared area's lines carry a mandatory username field, the per-user lines do not — and confusing them makes a job fail silently at its scheduled time. This module covers reading and writing both, and the strict order for migrating a job from one to the other without it running twice.

Two short parts; work them in order.

## How this module is organised

1. **[Part 1 — Where a cron job lives, and the format that follows](./course-01-where-a-cron-job-lives.md)** — the sources the `cron` daemon scans, six-field system-wide lines vs five-field per-user lines, the field grammar (lists, ranges, steps, names, `@`-shortcuts), and the silent failure when the two formats are mixed.
2. **[Part 2 — Migrating a job safely](./course-02-migrating-a-job-safely.md)** — `crontab -u <user> -e` and what it does under the hood, why hand-editing the spool file breaks trust, and the recreate → verify → delete → re-grep order that avoids both a coverage gap and a double-run race.

## Learning objectives

After this module you can:

- **Name** the locations `cron` reads, and state which are root-only and why.
- **Distinguish** a six-field system-wide cron line from a five-field per-user line, and convert one to the other.
- **Read and write** the five time fields including lists, ranges, `*/N` steps, and named weekdays/months.
- **Edit** another account's crontab with `sudo crontab -u <user> -e`, and explain why editing the spool file directly is unsafe.
- **Migrate** a job between the two areas in an order that never leaves it unscheduled and never leaves it duplicated.
- **Verify** ownership with `sudo crontab -u <user> -l` rather than by reading spool files.

## Before you start

Assumed: a Linux shell, `sudo`, an `$EDITOR` you are comfortable in, and the idea that a daemon runs commands on a schedule. No prior cron experience. Every command block states the shell and privilege it assumes and runs on any host with `cron`/`crond` installed.

## Where this fits

This is the first module of the section. Per-user cron is the "who runs this" half of scheduled work; the container modules that follow are the "in what environment does this run" half. Both share the theme of the section capstone: a scheduled workload that must run as the right account, in the right place, exactly once.
