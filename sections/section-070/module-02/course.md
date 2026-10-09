# Zypper Package Information Lookup

Astronaut, a good quartermaster never orders a crate blind. Installing something without knowing what it is, or which package would supply the file you are missing, is how a ship fills up with cargo nobody signed off on.

This module teaches the research side of `zypper`, the package manager on openSUSE and SUSE Linux Enterprise. Every command here only reads. None of them installs, removes or changes anything, and none needs `sudo`.

## Learning objectives

After this module you can:

- Choose between `zypper search`, `zypper info` and `zypper what-provides` for a given research question.
- Find a package by what it does with `zypper search`, and read its full details with `zypper info` without changing anything.
- Find the package that would supply a file that is not on the system yet, with `zypper what-provides`.
- List installed packages that match a pattern with `zypper search --installed-only`, instead of piping the output to `grep`.
- Explain why `rpm -qi` and `rpm -qf` cannot answer "what would a package that is not installed provide", and why `zypper` can.

## Before you start

Check that you have the knowledge and the tools this module expects before you begin.

### What you should already know

- **How to type a command at a prompt.**
- **What `zypper refresh` does.** It downloads each repository's catalogue (its metadata: which packages and versions it offers) and changes nothing that is installed.

### What you need

This module has no playground. The training ship (the lab virtual machine) runs Ubuntu 24.04, which has no `zypper`. The lab starts Docker on that ship and runs a real openSUSE Leap 15.6 container called `zypperbox`. A container is a sealed pod docked to the ship: its own crew and files, sharing the ship's reactor.

To try the examples, start the mission at the end of the last part, then step into the pod:

```sh
docker exec -it zypperbox bash
```

Run every command inside that shell. If Docker refuses with a permission error, run the same command with `sudo` in front.

## How this module is laid out

1. [Search, Info and What-Provides](./course-01-the-three-questions.md): `zypper search` (you know the topic, not the name), `zypper info` (the exact name, full details) and `zypper what-provides` (which package would supply a file, even one that is not installed).
2. [Installed-Only Search and the rpm Fallback](./course-02-installed-only-and-rpm-fallback.md): `zypper search --installed-only` as a built-in filter, and the trade-off between `zypper` (repository metadata) and `rpm -qi` and `rpm -qf` (the local database, no network).
   - Mission: [Zypper Package Information Lookup Lab](./labs/lab-01/README.md)
3. [Wrap-Up: Mission Debrief](./course-03-wrap-up.md)

## Why this matters

Exam tasks often describe a need ("brute-force blocking", "the `ip` command is missing") instead of naming a package. Picking the right research command turns that description into an exact package name in one step, before you change anything on the system.
