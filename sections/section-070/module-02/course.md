# Zypper Package Information Lookup

Installing something without knowing what it is, or which package would provide the file you are missing, is how systems accumulate surprises nobody signed off on. You built this instinct with `apt` and `dnf`; this module is the same discipline through zypper's command surface on a genuine openSUSE system. Every command here is read-only — none installs, removes, or changes anything, and none needs `sudo`.

Two short parts; work them in order.

## How this module is organised

1. **[Part 1 — The three research questions: search, info, what-provides](./course-01-the-three-questions.md)** — `zypper search` (topic known, name not), `zypper info` (exact name, full metadata), and `zypper what-provides` (repository metadata → even uninstalled packages).
2. **[Part 2 — Installed-only filtering, and the `rpm` fallback](./course-02-installed-only-and-rpm-fallback.md)** — `zypper search --installed-only` as a native filter (not `grep`), and the structural trade-off between `zypper` (repo metadata, sees uninstalled) and `rpm -qi`/`-qf` (local database, no network).

## Learning objectives

After this module you can:

- **Choose** between `zypper search`, `zypper info`, and `zypper what-provides` for a given research question.
- **Find** a package by function with `zypper search`, and read its full metadata with `zypper info` without changing anything.
- **Identify** the package that would provide an uninstalled file with `zypper what-provides`.
- **Filter** to installed packages by pattern with `zypper search --installed-only` instead of piping to `grep`.
- **Explain** why `rpm -qi`/`-qf` cannot answer "what would an uninstalled package provide" and `zypper` can.

## Before you start

Assumed: Module 1 (`zypper` basics), the `apt` / `dnf` information-lookup modules as context. This repo's only VM is Ubuntu 24.04, so the lab runs a real openSUSE Leap 15.6 container **`zypperbox`** — `docker exec -it zypperbox bash`. Every command is read-only; no `sudo` needed.

## Where this fits

This is the "look before you leap" companion to the zypper basic-operations module and the SUSE-family counterpart to the `apt` and `dnf` information-lookup modules. The `zypper what-provides` versus `rpm -qf` distinction is the same structural point the RPM module made, expressed in zypper's vocabulary.
