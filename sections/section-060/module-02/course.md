# Chapter 2: Rebuilding a Corrupted RPM Database

Every RPM-based system tracks what's installed in a local database under `/var/lib/rpm` — historically a set of Berkeley DB files, and on more recent Fedora/RHEL-family releases (including the Rocky Linux 9 you'll be working in for this lab) a `sqlite`-backed store instead. That database is what `rpm -qa`, `rpm -qi`, and every `dnf` transaction check against before doing anything. It's ordinary local state, which means it's exactly as vulnerable as any other local state to an interrupted write: a killed process mid-transaction, a hard power-off, a full disk during a package operation. When it happens, the *files on disk from already-installed packages are almost always still fine* — it's specifically the database's own internal consistency that's broken, and `rpm`/`dnf` start failing on operations that have nothing to do with the packages you're actually trying to install.

This chapter walks recognizing that specific symptom, safely backing up the database before touching anything, and rebuilding it.

---

## Working In This Lab: The `rpmbox` Container

Same setup as the previous chapter: this repo's only VM image is Ubuntu 24.04, so bootstrap installs Docker on the VM and starts a long-lived, privileged Rocky Linux 9 container named `rpmbox`. Every command in this chapter runs inside that container against its real RPM database, not on the Ubuntu host:

```bash
docker exec -it rpmbox bash
```

The corruption you're about to diagnose is real, too — bootstrap genuinely damages `rpmbox`'s RPM database file before you ever connect. Nothing here is simulated with fake error text; you'll be looking at an actual broken database and actually repairing it.

---

## Part I: Recognizing the Symptom

Classic RPM database corruption looks like this:

```bash
rpm -qa | tail -5
```
```text
error: rpmdbNextIterator: skipping h#191
error: rpmdb: damaged header instead of key
...
```

Or, on a `sqlite`-backed database like the one you're about to meet, something more like `error: rpmdb: BDB0113 Thread/process ... : unable to lock ...` or a flat `sqlite3` disk-image error surfacing through `rpm`'s own error reporting. Either way, the fingerprint is a **database-layer** error, not a package-layer one — before assuming corruption, rule out the two things that look superficially similar but have completely different fixes:

* **A genuine dependency conflict** names a specific missing or conflicting package clearly — nothing vague about "the database."
* **A disk-space problem** is confirmed or ruled out immediately with `df -h /var`, and `rpm`/`dnf` themselves usually say "no space left" outright.

If neither of those matches, and the error text specifically complains about the database itself, you're looking at corruption.

---

## Part II: Don't Assume the Backend

Older tutorials assume `/var/lib/rpm` holds Berkeley DB files — `Packages`, `__db.001`, `__db.002`, and so on. That assumption is stale on a Rocky Linux 9 (and RHEL 9+, and recent Fedora) system. These releases moved to a `sqlite`-backed store instead: a file named `rpmdb.sqlite`, alongside `-wal`/`-shm` sidecar files while a connection is active.

Check what's actually present before following any backend-specific instructions:

```bash
ls -la /var/lib/rpm
```

The remaining steps in this chapter work the same way regardless of which backend is present — `rpm --rebuilddb` detects and operates on whichever one actually exists — but confirming this upfront avoids chasing stale, backend-specific advice that doesn't apply to the system in front of you.

---

## Part III: Back Up Before You Touch Anything

This step is not optional busywork, even under time pressure:

```bash
sudo cp -a /var/lib/rpm /var/lib/rpm.bak-$(date +%s)
ls -d /var/lib/rpm.bak-*
```

`-a` (archive) preserves permissions, ownership, timestamps, and symlinks exactly. The database is the single authoritative record of what's installed on this system. If a repair attempt somehow makes things worse — or the actual root cause turns out to be something else entirely — this backup is the only way back to the current, broken-but-known state without a full system restore. It costs seconds. Skipping it costs, potentially, a system with *no* usable record of its own installed-package state at all.

---

## Part IV: Rebuilding the Database

```bash
sudo rpm --rebuilddb
```

`--rebuilddb` reconstructs the database's index and lookup structures from the header data already recorded in the existing database, discarding and rebuilding the corrupted indexing fresh. It repairs **database consistency**, not package files themselves — if a package's actual installed files were missing or damaged, `--rebuilddb` would do nothing to restore them (that's a `dnf reinstall` problem, a different fix for a different failure).

On systems with a newer, dedicated database-maintenance command available, the more current equivalent is:

```bash
sudo rpmdb --rebuilddb
```

Check `command -v rpmdb` to see if it exists on this system — some RPM releases split database-maintenance subcommands out of the monolithic `rpm` binary. Either accomplishes the same underlying repair.

---

## Part V: Verifying the Fix

```bash
rpm -qa | wc -l
```
This should complete cleanly, no interleaved error lines, and return a plausible package count.

```bash
sudo dnf check
```
This validates the installed-package set for internal consistency using the now-rebuilt database — confirming not just that `rpm -qa` works again, but that `dnf`'s own transaction-check machinery (the thing that was actually failing in the original symptom) is healthy too.

```bash
sudo dnf check-update
```
A full transaction-check pass completing normally, rather than failing at a database-related stage, is your independent confirmation the repair actually worked end to end.

---

## Self-Check and Verification

1. **What Rebuild Fixes**: Does `rpm --rebuilddb` restore a package's installed files if they were deleted from disk? *(Answer: No — it rebuilds database indexing/consistency from header data already present. Missing or damaged files are a `dnf reinstall`/`rpm -ivh --replacepkgs` problem.)*
2. **Backend Awareness**: What single command tells you which rpmdb backend a given system actually uses, instead of assuming? *(Answer: `ls -la /var/lib/rpm` — look for `Packages`/`__db.*` (Berkeley DB) versus `rpmdb.sqlite` (sqlite backend, the one Rocky Linux 9 uses).)*
3. **The Non-Negotiable Step**: Why back up `/var/lib/rpm` before running `--rebuilddb`, even when you're confident the rebuild will work? *(Answer: because a rollback path costs seconds and guarantees recovery if the rebuild doesn't go as expected, or the diagnosis turns out to be wrong — there is no good reason to skip it.)*
