# DNF Package Information Lookup

Astronaut, a good quartermaster never orders a crate blind. Before anything is installed you want to know what it is, what it needs, and, the more interesting question on a Red Hat family ship, which crate would even contain the file or command you are missing. This module is entirely read-only: every step answers a research question with `dnf` or `rpm`, before any action.

## Learning objectives

After this module you can:

- Find a package by what it does with `dnf search` and `dnf search all`, and by rough name with `dnf list available`.
- Read a package's full details and source repository with `dnf info`, without changing anything.
- Answer "which package provides this file or command?" with `dnf provides`, also for packages that are not installed.
- Explain why `dnf provides` can answer that question and `rpm -qf` cannot.
- List installed packages by an anchored name pattern, and choose `rpm -qi` or `rpm -qf` when an out-of-date catalogue matters.

## Before you start

Check that you have the knowledge and the tools this module expects.

### What you should already know

- **Basic `rpm` queries.** `rpm -qf <path>` names the installed package that owns a file, and `rpm -qi <name>` shows an installed package's details.
- **Basic `dnf` use.** `dnf install` installs a package with its dependencies, and `dnf` keeps a local copy of each repository's catalogue.

### What you need

There is no playground for this module. The lab machines run Ubuntu 24.04, so the mission starts a real Rocky Linux 9 **container** named `rpmbox` on the Ubuntu machine, with a fresh repository catalogue. A container is a sealed pod docked to the ship, with its own tools and its own package database. You open a shell inside it with `docker exec -it rpmbox bash`. Every command in this module is read-only, so you can also try them on any Rocky Linux 9 machine without risk.

## How this module is laid out

1. [Finding and Describing a Package](./course-01-search-and-describe.md): `dnf search` and `dnf search all`, `dnf list available '<glob>'`, and `dnf info` for full details from the catalogue.
2. [Provides Lookups and Cross-Checking with rpm](./course-02-provides-and-cross-referencing.md): `dnf provides` for "what would I install to get this file", why `rpm -qf` cannot answer that, listing installed packages by pattern, and when `rpm` gives the more trustworthy answer.
   - Mission: [DNF Package Information Lookup Lab](./labs/lab-01/question.md)
3. [Wrap-Up: Mission Debrief](./course-03-wrap-up.md)

## Why this matters

A script fails with "command not found", or a ticket asks for "something that blocks brute-force logins". In both cases the fastest fix starts with the right lookup, not a guessed package name. Research first also means you never install a package you have not read about.
