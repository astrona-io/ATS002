# Zypper Basic Package Operations

Astronaut, this module brings you to a new kind of supply depot. `zypper` is the quartermaster on openSUSE and SUSE Linux Enterprise, two Linux systems from the company SUSE. Like `apt` on Ubuntu and `dnf` on Red Hat systems, it refreshes the depot's catalogue first and then acts: it orders crates (packages) and every crate they depend on.

SUSE adds one thing the other two do not have in the same form. Besides "is there a newer version of this package?", SUSE systems ask a second question: "has the depot sent a **patch**, a reviewed safety notice that names exactly which crates to replace?" Mixing up `zypper patch` and `zypper update` is the most common way a SUSE administrator ships more change than a maintenance window allowed.

## Learning objectives

After this module you can:

- Refresh repository metadata with `zypper refresh`, and say what it changes and what it leaves alone.
- Tell `zypper list-updates` apart from `zypper list-patches`, and explain why the two lists can differ.
- Choose between `zypper patch` and `zypper update` from a written policy, and filter patches by category.
- Install and remove packages, and predict what happens to changed configuration files on removal.
- Read `cat /var/log/zypp/history` as a record of what happened, and undo a change by hand, because there is no `zypper history undo`.

## Before you start

Check that you have the knowledge and the tools this module expects before you begin.

### What you should already know

- **How to type a command at a prompt** and how to use `sudo`.
- **What a package and a repository are.** A package is a supply crate with a parts list, a version and the crates it needs. A repository is a supply depot that ships those crates.

### What is in your playground

Your playground is a training ship: one Ubuntu 24.04 virtual machine. That machine has no tools of this package family, so the playground runs a real openSUSE Leap 16.0 **container** named `zypperbox` on it. A container is a sealed pod docked to the ship: it has its own files and tools but shares the ship's reactor core (the kernel). Inside it, the package tools and the package database are all real.

- The community `network:utilities` repository added inside `zypperbox`.
- `telnet-server` installed. `fail2ban` not installed.

Start the playground, then open a terminal on it with `astrona ssh astro-zypper-everyday`. Step into the pod with `docker exec -it zypperbox bash` and run every package command in that shell. If Docker refuses with a permission error, put `sudo` in front. It is already set up with a container with one package to remove and one to install.

<!-- astrona:playground -->

## How this module is laid out

1. [Refresh, Updates and Patches](./course-01-refresh-updates-vs-patches.md): `zypper refresh`, the raw update list and the reviewed patch list, and why they can differ.
2. [Applying Patches or Updates](./course-02-applying-the-right-one.md): `zypper patch` (only what a patch covers) against `zypper update` (everything), and how to read a task's wording to choose.
3. [Installing, Removing and Reading History](./course-03-install-remove-history.md): `zypper install` and `zypper remove`, how the RPM layer keeps changed configuration files, and `cat /var/log/zypp/history` as a log with no undo.
   - Mission: [Zypper Basic Package Operations Lab](./labs/lab-01/README.md)
4. [Wrap-Up: Mission Debrief](./course-04-wrap-up.md)

## Why this matters

On the exam, a task that says "conservative" or "security patches only" wants `zypper patch`, not `zypper update`. Both commands finish without errors, so nothing warns you if you pick the wrong one. Knowing which question each command answers is what keeps the system inside its policy.

<!-- curriculum-practice -->
## Practice and assessment

- [Zypper Basic Package Operations Lab](labs/lab-01/question.md): Refresh metadata and list available updates and patches as two separate questions; Apply only patches, install one package and remove another; Read zypper's history to confirm what changed.
- [Zypper Research-Then-Act Capstone Lab](../capstone/labs/lab-01/question.md): Research a package by keyword and metadata before installing it; Apply only curated patches, install and remove packages, and read the history.
