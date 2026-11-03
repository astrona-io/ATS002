# DNF Basic Package Operations

Astronaut, on a Red Hat family ship the quartermaster is `dnf`. It orders supply crates (packages) from supply depots (repositories), along with every crate they depend on. The exam expects you to run its everyday loop without thinking: check what can be upgraded, apply the upgrades, install something new and retire something no longer needed.

`dnf` refreshes the depot catalogue by itself inside most commands, so it has no separate "update the catalogue" step like Debian's `apt update`. It also has one tool Debian's `apt` has no real match for: a transaction history that can undo a whole past operation as one unit.

## Learning objectives

After this module you can:

- Report available updates with `dnf check-update` and read its exit codes.
- Explain why `dnf` has no separate catalogue-update step and no `full-upgrade` split.
- Install and remove packages, and predict what happens to an edited `%config` file on removal.
- Clean up dependencies nothing needs any more with `dnf autoremove`, as a separate step.
- Read the transaction log with `dnf history` and `dnf history info`, and reverse a whole transaction with `dnf history undo`.

## Before you start

Check that you have the knowledge and the tools this module expects.

### What you should already know

- **How to use a Linux shell.** You can run commands with `sudo` and read their output.
- **What a package and a repository are.** A package is a file that holds a program and a list of what it needs. A repository is a server that offers packages to download.

### What is in your playground

Your playground is a training ship: one Ubuntu 24.04 virtual machine. That machine has no tools of this package family, so the playground runs a real Rocky Linux 9 **container** named `rpmbox` on it. A container is a sealed pod docked to the ship: it has its own files and tools but shares the ship's reactor core (the kernel). Inside it, the package tools and the package database are all real.

- The EPEL repository enabled inside `rpmbox`.
- `telnet` installed. `fail2ban` and `mtr` not installed.

Start the playground, then open a terminal on it with `astrona ssh astro-dnf-everyday`. Step into the pod with `docker exec -it rpmbox bash` and run every package command in that shell. If Docker refuses with a permission error, put `sudo` in front. It is already set up with a container with EPEL enabled, one package to remove and one to install.

<!-- astrona:playground -->

## How this module is laid out

1. [The Everyday dnf Loop](./course-01-the-dnf-loop.md): `dnf check-update` and its exit code `100`, the automatic catalogue refresh, `dnf upgrade` as one plan, and `dnf install` with the EPEL habit.
2. [Removing and Transaction History](./course-02-removing-and-history.md): `dnf remove` and how RPM handles `%config` files, `dnf autoremove` for leftovers, and `dnf history undo` to reverse a whole transaction.
   - Mission: [DNF Basic Package Operations Lab](./labs/lab-01/question.md)
3. [Wrap-Up: Mission Debrief](./course-03-wrap-up.md)

## Why this matters

Routine package maintenance is most of an administrator's package work. Doing it in the right order, and cleaning up after yourself, keeps a server predictable. When a transaction pulls in more than anyone wanted, `dnf history undo` puts the ship back exactly as it was, in one step.
