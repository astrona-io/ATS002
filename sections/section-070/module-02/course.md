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

### What is in your playground

Your playground is a training ship: one Ubuntu 24.04 virtual machine. That machine has no tools of this package family, so the playground runs a real openSUSE Leap 15.6 **container** named `zypperbox` on it. A container is a sealed pod docked to the ship: it has its own files and tools but shares the ship's reactor core (the kernel). Inside it, the package tools and the package database are all real.

- A fresh repository catalogue inside `zypperbox`.
- `python3-base` and `python3-pip` installed.
- An empty folder `/root/answers` inside the container for saving what you find.

Start the playground, then open a terminal on it with `astrona ssh astro-zypper-package-research`. Step into the pod with `docker exec -it zypperbox bash` and run every package command in that shell. If Docker refuses with a permission error, put `sudo` in front. It is already set up with a container for read-only package research.

<!-- astrona:playground -->

## How this module is laid out

1. [Search, Info and What-Provides](./course-01-the-three-questions.md): `zypper search` (you know the topic, not the name), `zypper info` (the exact name, full details) and `zypper what-provides` (which package would supply a file, even one that is not installed).
2. [Installed-Only Search and the rpm Fallback](./course-02-installed-only-and-rpm-fallback.md): `zypper search --installed-only` as a built-in filter, and the trade-off between `zypper` (repository metadata) and `rpm -qi` and `rpm -qf` (the local database, no network).
   - Mission: [Zypper Package Information Lookup Lab](./labs/lab-01/README.md)
3. [Wrap-Up: Mission Debrief](./course-03-wrap-up.md)

## Why this matters

Exam tasks often describe a need ("brute-force blocking", "the `ip` command is missing") instead of naming a package. Picking the right research command turns that description into an exact package name in one step, before you change anything on the system.
