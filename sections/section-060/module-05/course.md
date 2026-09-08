# Chapter 5: DNF Package Groups

"Give this build server a full development toolchain" is a different request from "install a package" — dozens of packages, installed and later retired together as one coherent unit. APT has no first-class answer; `dnf` does, because RHEL-family repository metadata itself carries the concept: a **group** is a named set of packages with mandatory, default, and optional membership tiers, published by the repository maintainer. This module discovers what groups a system offers, inspects one's real membership before committing, installs it, confirms what landed, and removes it — including the removal detail that trips people up.

Three short parts; work them in order.

## How this module is organised

1. **[Part 1 — What a group is, and discovering what exists](./course-01-what-a-group-is-and-discovering.md)** — a group as maintainer-published comps metadata, `dnf group list`, and `--hidden` for the groups the plain listing omits.
2. **[Part 2 — Inspecting membership, and installing](./course-02-inspecting-and-installing.md)** — `dnf group info` and the Mandatory / Default / Optional tiers (only the first two install by default), `dnf group install`, and `--with-optional`.
3. **[Part 3 — Confirming what landed, and removing cleanly](./course-03-confirming-and-removing.md)** — the installed-indicator and `dnf group list installed`, and `dnf group remove` semantics: it removes what `dnf` tracked as installed *by* the group, not raw membership (`automake` survives, `gcc` does not).

## Learning objectives

After this module you can:

- **Explain** what a `dnf` group is and where its definition comes from.
- **Discover** available and hidden groups with `dnf group list` / `--hidden`.
- **Read** a group's three membership tiers and predict what a plain install brings in.
- **Install** a group with and without its optional members.
- **Confirm** what landed with `dnf group info` and `dnf group list installed`.
- **Predict** exactly which packages `dnf group remove` will and will not remove, based on install-time tracking.

## Before you start

Assumed: Modules 1–4 (`rpm`, the `dnf` loop, information lookup), a Linux shell, `sudo`. This repo's only VM is Ubuntu 24.04, so the lab runs a real Rocky Linux 9 container **`rpmbox`** — `docker exec -it rpmbox bash`.

## Where this fits

Package groups are the RPM-family answer to bulk installs — the counterpart to the Debian bulk-operations module. The install-tracking behaviour of `dnf group remove` is the subtle point the section capstone tests.
