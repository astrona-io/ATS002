# Zypper Basic Package Operations

`zypper`, the package tool on openSUSE and SUSE Linux Enterprise, tells the same refresh-then-act story as `apt` and `dnf` — with one extra chapter nobody else writes. Alongside "is there a newer version of this package", SUSE distributions ask a second, separate question: "has the vendor published a **patch** that covers this system?" Those are not the same question, and confusing `zypper patch` with `zypper update` is the most common way a SUSE admin drifts out of policy or ships more change than a maintenance window intended.

Three short parts; work them in order.

## How this module is organised

1. **[Part 1 — Refresh, and the two questions: updates vs. patches](./course-01-refresh-updates-vs-patches.md)** — `zypper refresh`, `list-updates` (raw version arithmetic) vs `list-patches` (curated, categorised patch objects), and why the two lists legitimately differ.
2. **[Part 2 — Applying the right one: `zypper patch` vs `zypper update`](./course-02-applying-the-right-one.md)** — `zypper patch` (only patch-covered, with `--category security`) vs `zypper update` (everything), and reading a task's wording to choose.
3. **[Part 3 — Installing, removing, and reading history](./course-03-install-remove-history.md)** — `zypper in` / `rm` with automatic RPM `.rpmsave` handling (no `purge`), and `zypper history` as an audit log with no `undo`.

## Learning objectives

After this module you can:

- **Refresh** repository metadata and explain what `zypper refresh` does and does not change.
- **Distinguish** `zypper list-updates` from `zypper list-patches` and explain why they differ.
- **Choose** between `zypper patch` and `zypper update` from a policy description, and filter patches by category.
- **Install** and **remove** packages, and predict RPM's per-file config handling on removal.
- **Read** `zypper history` as an audit trail, and reverse a change manually because there is no `zypper history undo`.

## Before you start

Assumed: the `apt` and `dnf` basic-operations modules as context, a Linux shell, `sudo`. This repo's only VM is Ubuntu 24.04, so the lab runs a real openSUSE Leap 15.6 container **`zypperbox`** — `docker exec -it zypperbox bash`, and run every `zypper` command there (the Ubuntu host has no `zypper`).

## Where this fits

This is the SUSE-family everyday loop, the third of the three package-manager families in the domain. The patch-vs-update distinction is the one thing genuinely unique to SUSE and the point the section leans on.
