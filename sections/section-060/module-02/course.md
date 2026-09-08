# Chapter 2: Rebuilding a Corrupted RPM Database

Every RPM system tracks what is installed in a local database under `/var/lib/rpm` — Berkeley DB on older releases, a `sqlite` store on RHEL 9 / Rocky 9 / recent Fedora. That database is what `rpm -qa`, `rpm -qi`, and every `dnf` transaction check consult first, and it is exactly as vulnerable as any local state to an interrupted write. When it breaks, the installed packages' files are almost always fine — it is the database's own consistency that is broken, and `rpm`/`dnf` start failing on operations unrelated to whatever you were installing. This module is recognising that specific symptom, backing up before touching anything, and rebuilding.

Two short parts; work them in order.

## How this module is organised

1. **[Part 1 — Recognising the symptom, and not assuming the backend](./course-01-recognising-the-symptom.md)** — the database-layer error fingerprint, ruling out the dependency-conflict and disk-space look-alikes, and checking `ls -la /var/lib/rpm` for the sqlite vs Berkeley DB backend.
2. **[Part 2 — Back up, rebuild, verify](./course-02-backup-rebuild-verify.md)** — `cp -a` the database first, `rpm --rebuilddb` (what it fixes and what it does not), and verifying with `rpm -qa`, `dnf check`, and `dnf check-update`.

## Learning objectives

After this module you can:

- **Distinguish** an RPM database-layer failure from a dependency conflict and from a full `/var`.
- **Identify** which database backend a system uses without assuming.
- **Back up** `/var/lib/rpm` faithfully before any repair, and explain why it is non-negotiable.
- **Rebuild** the database with `rpm --rebuilddb`, and state what it reconstructs (indexes from headers) versus what it cannot (missing package files).
- **Verify** the repair end to end with `rpm -qa`, `dnf check`, and `dnf check-update`.

## Before you start

Assumed: Module 1 (`rpm` query basics), a Linux shell, `sudo`. This repo's only VM is Ubuntu 24.04, so the lab runs a real Rocky Linux 9 container **`rpmbox`** — `docker exec -it rpmbox bash`, and the corruption you diagnose is genuinely inflicted on that container's database by bootstrap, not faked error text.

## Where this fits

This module depends on Module 1's ability to tell a database-layer message from a package-layer one, and it is the recovery half of RPM-family package management — the section capstone stages a system whose rpmdb was left inconsistent by an interrupted operation.
