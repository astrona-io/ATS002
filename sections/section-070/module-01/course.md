# Zypper Basic Package Operations

Astronaut, this module brings you to a new kind of supply depot. `zypper` is the quartermaster on openSUSE and SUSE Linux Enterprise, two Linux systems from the company SUSE. Like `apt` on Ubuntu and `dnf` on Red Hat systems, it refreshes the depot's catalogue first and then acts: it orders crates (packages) and every crate they depend on.

SUSE adds one thing the other two do not have in the same form. Besides "is there a newer version of this package?", SUSE systems ask a second question: "has the depot sent a **patch**, a reviewed safety notice that names exactly which crates to replace?" Mixing up `zypper patch` and `zypper update` is the most common way a SUSE administrator ships more change than a maintenance window allowed.

## Learning objectives

After this module you can:

- Refresh repository metadata with `zypper refresh`, and say what it changes and what it leaves alone.
- Tell `zypper list-updates` apart from `zypper list-patches`, and explain why the two lists can differ.
- Choose between `zypper patch` and `zypper update` from a written policy, and filter patches by category.
- Install and remove packages, and predict what happens to changed configuration files on removal.
- Read `zypper history` as a record of what happened, and undo a change by hand, because there is no `zypper history undo`.

## Before you start

Check that you have the knowledge and the tools this module expects before you begin.

### What you should already know

- **How to type a command at a prompt** and how to use `sudo`.
- **What a package and a repository are.** A package is a supply crate with a parts list, a version and the crates it needs. A repository is a supply depot that ships those crates.

### What you need

This module has no playground. The training ship (the lab virtual machine) runs Ubuntu 24.04, which has no `zypper`. Each lab in this module starts Docker on that ship and runs a real openSUSE Leap 15.6 container called `zypperbox` next to it. A container is a sealed pod docked to the ship: it has its own crew and its own files, but shares the ship's reactor.

To try the examples, start the mission at the end of the last part, then step into the pod:

```sh
docker exec -it zypperbox bash
```

Run every `zypper` command inside that shell. If Docker refuses with a permission error, run the same command with `sudo` in front.

## How this module is laid out

1. [Refresh, Updates and Patches](./course-01-refresh-updates-vs-patches.md): `zypper refresh`, the raw update list and the reviewed patch list, and why they can differ.
2. [Applying Patches or Updates](./course-02-applying-the-right-one.md): `zypper patch` (only what a patch covers) against `zypper update` (everything), and how to read a task's wording to choose.
3. [Installing, Removing and Reading History](./course-03-install-remove-history.md): `zypper install` and `zypper remove`, how the RPM layer keeps changed configuration files, and `zypper history` as a log with no undo.
   - Mission: [Zypper Basic Package Operations Lab](./labs/lab-01/README.md)
4. [Wrap-Up: Mission Debrief](./course-04-wrap-up.md)

## Why this matters

On the exam, a task that says "conservative" or "security patches only" wants `zypper patch`, not `zypper update`. Both commands finish without errors, so nothing warns you if you pick the wrong one. Knowing which question each command answers is what keeps the system inside its policy.
