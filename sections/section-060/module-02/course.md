# Rebuilding a Corrupted RPM Database

Astronaut, every Red Hat family ship keeps a ledger of every supply crate on board: the **RPM database** under `/var/lib/rpm`. Older releases store it in Berkeley DB files. RHEL 9, Rocky Linux 9 and recent Fedora store it in a `sqlite` file. `rpm -qa`, `rpm -qi` and every `dnf` transaction read this ledger first.

The ledger can break like any other file, for example when a write is cut off halfway. When it breaks, the installed packages' files are almost always fine. It is the ledger itself that is damaged, so `rpm` and `dnf` fail on tasks that have nothing to do with what you were installing. This module teaches you to recognise that symptom, tell it apart from look-alikes, back the ledger up, and rebuild it.

## Learning objectives

After this module you can:

- Tell an RPM database failure apart from a dependency problem and from a full `/var` filesystem.
- Find out which database backend a system uses, without assuming.
- Back up `/var/lib/rpm` faithfully before any repair, and explain why you never skip it.
- Rebuild the database with `rpm --rebuilddb`, and say what it rebuilds (indexes from the stored headers) and what it cannot fix (missing package files).
- Prove the repair end to end with `rpm -qa`, `dnf check` and `dnf check-update`.

## Before you start

Check that you have the knowledge and the tools this module expects.

### What you should already know

- **Basic `rpm` queries.** `rpm -qa` lists every installed package, `rpm -qi <name>` shows one package's details, and `rpm -q <name>` says whether a package is installed.
- **How to use a Linux shell.** You can run commands with `sudo` and read error messages.

### What you need

There is no playground for this module. The lab machines run Ubuntu 24.04, so each mission starts a real Rocky Linux 9 **container** named `rpmbox` on the Ubuntu machine. A container is a sealed pod docked to the ship, with its own tools and its own RPM database. You open a shell inside it with `docker exec -it rpmbox bash`. The damage you repair there is real: the mission's setup really breaks that container's database file.

## How this module is laid out

1. [Recognising a Broken RPM Database](./course-01-recognising-the-symptom.md): what a database-layer error looks like, how to rule out a dependency problem and a full disk, and how to check whether the backend is `sqlite` or Berkeley DB.
   - Mission: [RPM Database: Corruption Look-Alike Lab](./labs/lab-02/question.md)
2. [Back Up, Rebuild, Verify](./course-02-backup-rebuild-verify.md): copying the database with `cp -a`, `rpm --rebuilddb`, and proving the repair with `rpm -qa`, `dnf check` and `dnf check-update`.
   - Mission: [Rebuilding a Corrupted RPM Database Lab](./labs/lab-01/question.md)
3. [Wrap-Up: Mission Debrief](./course-03-wrap-up.md)

## Why this matters

A broken ledger stops every package task on a server: no installs, no updates, no security fixes. The rebuild itself is one command. The skill is knowing *when* it is the right command, and never running it without a backup.
