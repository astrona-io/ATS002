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

### What is in your playground

Your playground is a training ship: one Ubuntu 24.04 virtual machine. That machine has no tools of this package family, so the playground runs a real Rocky Linux 9 **container** named `rpmbox` on it. A container is a sealed pod docked to the ship: it has its own files and tools but shares the ship's reactor core (the kernel). Inside it, the package tools and the package database are all real.

- The EPEL repository enabled inside `rpmbox`, and a fresh repository catalogue.
- A few `python3-*` packages installed.

Start the playground, then open a terminal on it with `astrona ssh astro-dnf-package-research`. Step into the pod with `docker exec -it rpmbox bash` and run every package command in that shell. If Docker refuses with a permission error, put `sudo` in front. It is already set up with a container for read-only package research.

<!-- astrona:playground -->

## How this module is laid out

1. [Finding and Describing a Package](./course-01-search-and-describe.md): `dnf search` and `dnf search all`, `dnf list available '<glob>'`, and `dnf info` for full details from the catalogue.
2. [Provides Lookups and Cross-Checking with rpm](./course-02-provides-and-cross-referencing.md): `dnf provides` for "what would I install to get this file", why `rpm -qf` cannot answer that, listing installed packages by pattern, and when `rpm` gives the more trustworthy answer.
   - Mission: [DNF Package Information Lookup Lab](./labs/lab-01/question.md)
3. [Wrap-Up: Mission Debrief](./course-03-wrap-up.md)

## Why this matters

A script fails with "command not found", or a ticket asks for "something that blocks brute-force logins". In both cases the fastest fix starts with the right lookup, not a guessed package name. Research first also means you never install a package you have not read about.
