# Chapter 1: RPM Low-Level Package Management

When `dnf install` finishes, a quieter tool did the work: `rpm` unpacked the files and wrote them into a local database under `/var/lib/rpm`. `dnf` is the network-and-dependency layer; `rpm` is the one-file-at-a-time installer with no concept of a repository. Most days you never call it directly — until someone hands you a standalone `.rpm`, or you need to check whether an installed package's files have drifted from what was recorded. This module operates at that lower level: inspect a `.rpm` before trusting it, install it, ask ownership questions both ways, and verify integrity.

Three short parts; work them in order.

## How this module is organised

1. **[Part 1 — What `rpm` knows, and inspecting a `.rpm` before you trust it](./course-01-rpm-scope-and-inspecting.md)** — the "one thing, no repository" model, and `rpm -qip` / `-qlp` / `-qp --requires` to read a `.rpm` file's header — with the `-p` modifier that decides file vs. installed database.
2. **[Part 2 — Installing directly, and ownership queries in both directions](./course-02-installing-and-ownership.md)** — `rpm -ivh` and why it *refuses* on a missing dependency (unlike `dpkg -i`), `dnf install ./file.rpm` as the practical alternative, and `-qf` (file → package) / `-ql` (package → files) with the `-p` flag table.
3. **[Part 3 — Verifying integrity](./course-03-verifying-integrity.md)** — `rpm -V` and its nine-column per-attribute codes (`S`, `5`, `T`, …), the `c` config marker that changes how you read them, and `--requires` vs `--provides`.

## Learning objectives

After this module you can:

- **State** what `rpm` operates on, and use `-p` correctly to switch between a `.rpm` file and the installed database.
- **Inspect** a `.rpm` file's metadata, file list, and declared requirements without changing the system.
- **Install** a standalone `.rpm`, and explain why `rpm -ivh` refuses a missing dependency and `dnf install ./file.rpm` does not.
- **Map** a file to its owning package (`rpm -qf`) and a package to its files (`rpm -ql`).
- **Read** `rpm -V` output — the per-attribute codes and the file-type marker — and tell a benign config edit from an integrity concern.
- **Explain** how `--provides` capabilities drive dependency resolution independent of package names.

## Before you start

Assumed: a Linux shell, `sudo`, and Debian's `dpkg` module as useful contrast. This repo's only VM is Ubuntu 24.04, so the lab bootstrap runs a real Rocky Linux 9 container named **`rpmbox`**; get a shell with `docker exec -it rpmbox bash` and run every `rpm` command from there. Everything inside is a genuine Rocky 9 userspace and RPM database — nothing simulated.

## Where this fits

This is the RPM-family counterpart to the Debian `dpkg` module. The `-p` file-vs-name distinction and `rpm -V` integrity reading are exactly what the section builds on — the rpmdb-rebuild module assumes you can tell a database-layer failure from a package-layer one.
