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

### What is in your playground

Your playground is a training ship: one Ubuntu 24.04 virtual machine, already set up with a machine for read-only package research.

- A few `python3-*` packages installed, so `apt list --installed` has something to match.
- The folder `/opt/course/apt-research`, owned by the `student` user, for saving what you find.
- The normal `apt`, `apt-cache` and `dpkg` tools. Every research command is read-only.

Start the playground, then open a terminal on it with `astrona ssh astro-apt-package-research`. The hands-on steps in the parts build on each other on this one running ship. Every command block says which shell and which rights it expects.

<!-- astrona:playground -->

## How this module is laid out

1. [Finding And Describing A Package](./course-01-finding-and-describing.md): `apt search` (keyword in name and description) versus `apt list '<glob>'` (name only), and `apt show` for the full declared metadata of one package.
2. [Installed Versus Candidate](./course-02-installed-vs-candidate.md): `apt-cache policy` (Installed, Candidate and a priority-ranked version table naming each repository), listing installed packages by an anchored pattern, and when `dpkg -s` is the more trustworthy answer.
   - Mission: APT Package Information Lookup Lab
3. [Wrap-Up: Mission Debrief](./course-03-wrap-up.md)

## Why this matters

`apt-cache policy` is the command that ties all package work together. It tells you which repository and which version any later action will really touch. A minute of read-only research before a change saves hours of finding out afterwards why a server runs a version nobody chose.

<!-- curriculum-practice -->
## Practice and assessment

- [APT Package Information Lookup Lab](labs/lab-01/question.md): Search for packages by keyword and show one package's metadata without installing it; Compare installed and candidate versions and their source with apt-cache policy; List installed packages by name pattern and list upgradable packages.
- [New App Server Onboarding Capstone Lab](../capstone/labs/lab-01/question.md): Add a vendor repository with a dedicated keyring and install and hold its exact version; Recover a half-configured package and hold a whole package family by pattern; Record which version and repository APT would install, without installing.
