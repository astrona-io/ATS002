# dpkg Low-Level Package Management

Astronaut, when `apt install` finishes, a quieter tool did the real work. `dpkg` unpacked the files and wrote them into the ship's package database. Think of `apt` as the quartermaster, who orders crates and every crate they depend on. `dpkg` is the loading crew: it unpacks the one crate it is handed, without ordering anything and without knowing that any depot exists.

Most days you never call `dpkg` yourself. That changes when someone hands you a standalone `.deb` file, or when an interrupted install leaves the ship's package records half-finished. This module works at that lower level. You inspect a `.deb` before trusting it, install it, ask who owns which file, and recover a package that is neither cleanly installed nor gone.

## Learning objectives

After this module you can:

- Say what `dpkg` works on and what it cannot do, and explain why `dpkg -i` cannot fetch a missing dependency.
- Inspect a `.deb` file's metadata (`dpkg -I`) and its file list (`dpkg -c`) without changing the system.
- Install a standalone `.deb` and complete it with `apt --fix-broken install` when a dependency is missing.
- Find the package that owns a file (`dpkg -S`) and the files that belong to a package (`dpkg -L`), and keep the file-path flags and package-name flags apart.
- Read the status column of `dpkg -l`, and tell a package left in the middle of an install from one that is cleanly installed or removed.
- Recover an interrupted package with `dpkg --configure -a` followed by `apt --fix-broken install`.

## Before you start

Check that you have the knowledge and the tools this module expects before you begin.

### What you should already know

- **How to run a command with `sudo`.** Installing and recovering packages needs the captain's authority.
- **The basics of `apt`.** `apt install <name>` fetches a package and the packages it needs from configured repositories.

### What you need

- A terminal on an Ubuntu 24.04 machine. The examples use the internal tool `logtail-utils` and its file `/home/candidate/downloads/logtail-utils_2.3.1_amd64.deb`; on another machine, try the read-only commands on any `.deb` file you have.
- Or a running lab machine: start the mission with `astrona run` and open a terminal on it with `astrona ssh <lab name>`. The mission gives you the exact commands.

## How this module is laid out

1. [What dpkg Knows And Inspecting A .deb](./course-01-dpkg-scope-and-inspecting-a-deb.md): the "one thing at a time, no repository" model, and `dpkg -I` and `dpkg -c` as read-only looks inside a `.deb` file.
2. [Installing Directly And Asking Who Owns What](./course-02-installing-and-ownership-queries.md): `dpkg -i` and the `apt --fix-broken install` habit for a missing dependency, then `-S` (file to package), `-L` (package to files) and the map of which flag takes what.
3. [Status Codes And Recovering An Interrupted Package](./course-03-status-codes-and-recovery.md): reading the `dpkg -l` status column (`ii`, `iU`, `iF`, `rc`), what an interruption leaves behind, and `dpkg --configure -a` followed by `apt --fix-broken install`.
   - Mission: dpkg Low-Level Package Management Lab
4. [Wrap-Up: Mission Debrief](./course-04-wrap-up.md)

## Why this matters

A package stuck halfway through an install does not shout. It shows up as two quiet letters in a list, and the software may not run. Reading those letters and knowing the fixed two-command recovery turns "the package system looks broken" into a two-minute job, and the exam expects you to do it.
