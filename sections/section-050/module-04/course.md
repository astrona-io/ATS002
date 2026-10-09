# APT Package Information Lookup

Astronaut, "it installed without an error" and "it is the version and source I expected" are two different claims. Mixing them up is how a ship collects quiet surprises: the wrong build, an older version than you thought, or a crate from a depot nobody meant to trust.

Before you install, remove or upgrade anything, a whole layer of `apt` tools exists only to answer questions. None of them changes the ship. This module is that research layer: what you reach for *before* you commit to a change.

## Learning objectives

After this module you can:

- Find a package by what it does with `apt search`, and by a rough name with `apt list '<glob>'`.
- Read a package's declared dependencies and size with `apt show`, without changing the system.
- Read `apt-cache policy`: the Installed line, the Candidate line, the priorities, and which repository each version comes from.
- List installed packages whose names start with a prefix, using an anchored `grep`.
- Choose `dpkg -s` over `apt show` or `apt-cache policy` when the question is about what is installed and the catalogue may be old.

## Before you start

Check that you have the knowledge and the tools this module expects before you begin.

### What you should already know

- **That `apt` reads repositories and keeps a local catalogue.** `sudo apt update` refreshes that catalogue.
- **How to save command output to a file with `>`.** The mission asks you to record your answers in files.
- **What `grep` does.** It prints only the lines that match a pattern.

### What you need

- A terminal on an Ubuntu 24.04 machine. Every command in this module is read-only, so you can try them on any machine without changing it.
- Or a running lab machine: start the mission with `astrona run` and open a terminal on it with `astrona ssh <lab name>`. The mission gives you the exact commands.

## How this module is laid out

1. [Finding And Describing A Package](./course-01-finding-and-describing.md): `apt search` (keyword in name and description) versus `apt list '<glob>'` (name only), and `apt show` for the full declared metadata of one package.
2. [Installed Versus Candidate](./course-02-installed-vs-candidate.md): `apt-cache policy` (Installed, Candidate and a priority-ranked version table naming each repository), listing installed packages by an anchored pattern, and when `dpkg -s` is the more trustworthy answer.
   - Mission: APT Package Information Lookup Lab
3. [Wrap-Up: Mission Debrief](./course-03-wrap-up.md)

## Why this matters

`apt-cache policy` is the command that ties all package work together. It tells you which repository and which version any later action will really touch. A minute of read-only research before a change saves hours of finding out afterwards why a server runs a version nobody chose.
