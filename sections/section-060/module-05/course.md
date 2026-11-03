# DNF Package Groups

Astronaut, "give this build ship a full development toolchain" is a different order from "load one crate". It means dozens of packages, installed together and later retired together. On a Red Hat family ship, `dnf` answers it with a **package group**: a ready-made bundle of crates for one job. The repository maintainer publishes the bundle in the repository's own catalogue, with three tiers of members: mandatory, default and optional. Debian's `apt` has no first-class match for this.

In this module you discover which groups a system offers, inspect one group's real members before you commit, install it, confirm what landed and remove it again, including the removal detail that trips people up.

## Learning objectives

After this module you can:

- Explain what a `dnf` group is and where its definition comes from.
- Discover visible and hidden groups with `dnf group list` and `dnf group list --hidden`.
- Read a group's three member tiers and predict what a plain install brings in.
- Install a group with and without its optional members.
- Confirm what landed with `dnf group info` and `dnf group list installed`.
- Predict which packages `dnf group remove` will and will not remove, based on what `dnf` recorded at install time.

## Before you start

Check that you have the knowledge and the tools this module expects.

### What you should already know

- **Basic `dnf` use.** `dnf install`, `dnf remove` and `dnf list installed`.
- **Basic `rpm` queries.** `rpm -q <name>` says whether a package is installed.

### What is in your playground

Your playground is a training ship: one Ubuntu 24.04 virtual machine. That machine has no tools of this package family, so the playground runs a real Rocky Linux 9 **container** named `rpmbox` on it. A container is a sealed pod docked to the ship: it has its own files and tools but shares the ship's reactor core (the kernel). Inside it, the package tools and the package database are all real.

- `automake` installed on its own, before any group was touched. It is also a member of the `Development Tools` group.
- The `Development Tools` group itself not installed.

Start the playground, then open a terminal on it with `astrona ssh astro-dnf-package-groups`. Step into the pod with `docker exec -it rpmbox bash` and run every package command in that shell. If Docker refuses with a permission error, put `sudo` in front. It is already set up with a container where one group member is already installed on its own.

<!-- astrona:playground -->

## How this module is laid out

1. [What a Group Is and Finding One](./course-01-what-a-group-is-and-discovering.md): a group as repository-published metadata, `dnf group list`, and `--hidden` for the groups the plain listing leaves out.
2. [Inspecting and Installing a Group](./course-02-inspecting-and-installing.md): `dnf group info` and the Mandatory, Default and Optional tiers, `dnf group install`, and `--with-optional`.
3. [Confirming and Removing a Group](./course-03-confirming-and-removing.md): checking what landed with `dnf group list installed`, and why `dnf group remove` takes what the group installed, not every member.
   - Mission: [DNF Package Groups Lab](./labs/lab-01/question.md)
4. [Wrap-Up: Mission Debrief](./course-04-wrap-up.md)

## Why this matters

Groups turn "install the forty packages a build server needs" into one reviewed command, and "retire them" into another. The catch is in the removal: if you do not know what `dnf` tracks, you either leave packages behind or are surprised by what disappears. The exam likes exactly that kind of question.
