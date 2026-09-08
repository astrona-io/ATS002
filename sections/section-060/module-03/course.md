# Chapter 3: DNF Basic Package Operations

LFCS expects fluency with the everyday `dnf` lifecycle on RHEL/Fedora-family systems: check what is upgradable, apply upgrades, install something new, retire something no longer needed. `dnf` folds metadata refresh into most commands, which changes the model slightly from APT's explicit two-step `update` / `upgrade` — and `dnf` has one capability APT has no real equivalent for: a genuinely transactional history that can undo an entire past operation as a unit.

Two short parts; work them in order.

## How this module is organised

1. **[Part 1 — The everyday `dnf` loop](./course-01-the-dnf-loop.md)** — `dnf check-update` (exit `100`), automatic metadata refresh (no `apt update` step), `dnf upgrade` as one solver-computed plan, and `dnf install` (with the EPEL habit).
2. **[Part 2 — Removing, and transactional history](./course-02-removing-and-history.md)** — `dnf remove` and RPM's automatic per-file `%config` → `.rpmsave` handling, `dnf autoremove` for orphans, and `dnf history` / `history undo` to reverse a whole past transaction atomically.

## Learning objectives

After this module you can:

- **Report** available updates with `dnf check-update` and interpret its exit codes.
- **Explain** why there is no separate `update` step and no `full-upgrade` split in `dnf`.
- **Install** and **remove** packages, and predict what happens to a modified `%config` file on removal.
- **Clean up** orphaned dependencies with `dnf autoremove` as a distinct step.
- **Inspect** transaction history with `dnf history` / `history info` and reverse a whole transaction with `dnf history undo`.

## Before you start

Assumed: a Linux shell, `sudo`, and the Debian `apt` module as contrast. This repo's only VM is Ubuntu 24.04, so the lab runs a real Rocky Linux 9 container **`rpmbox`** with EPEL enabled — `docker exec -it rpmbox bash`, and run every command there.

## Where this fits

This is the RPM-family everyday loop, the counterpart to the Debian `apt` basic-operations module. `dnf history undo` in particular is the recovery tool the section capstone expects when a transaction bundled in more than intended.
