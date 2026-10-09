# APT Basic Package Operations

Astronaut, most package work on a ship is one ordinary loop. You find out what is new, apply it, bring one more crate on board, and retire a crate you no longer need. The quartermaster, `apt`, does every step of it.

The loop is simple, but it is also where most avoidable mistakes in this topic happen. The reason is that pairs of commands sound alike and do different things: `update` and `upgrade`, `remove` and `purge`. This module walks the loop the way you would in a real maintenance window, with the focus on those differences.

## Learning objectives

After this module you can:

- Say what `apt update` changes about installed packages (nothing), and why running it first matters.
- Preview pending upgrades with `apt list --upgradable`.
- Explain why a package is "kept back", and choose `apt full-upgrade` on purpose when it is.
- Install a package and its dependencies in one transaction.
- Choose between `apt remove` and `apt purge` from a task's wording, and recognise the `rc` state.
- Clean up orphaned dependencies with `apt autoremove` as a separate step.
- Choose `apt` for work at the keyboard and `apt-get` or `apt-cache` for scripts.

## Before you start

Check that you have the knowledge and the tools this module expects before you begin.

### What you should already know

- **How to run a command with `sudo`.** Every command that changes packages needs the captain's authority.
- **That `apt` reads its repositories from `/etc/apt/sources.list` and `/etc/apt/sources.list.d/`.**
- **The `dpkg -l` status codes.** `ii` means installed and configured; `rc` means removed with configuration files left behind.

### What you need

- A terminal on an Ubuntu 24.04 machine where you may install and remove packages.
- Or a running lab machine: start the mission with `astrona run` and open a terminal on it with `astrona ssh <lab name>`. The mission gives you the exact commands.

## How this module is laid out

1. [Update Is Not Upgrade](./course-01-update-is-not-upgrade.md): `apt update` downloads the package index again and changes nothing installed; why a stale index breaks later commands; `apt list --upgradable` as the read-only preview.
2. [Applying Upgrades And Installing](./course-02-applying-upgrades-and-installing.md): `apt upgrade` moves versions but never adds or removes packages, which produces the "kept back" list; `apt full-upgrade` when a change of the package set is confirmed safe; `apt install`.
3. [Removing Cleanly](./course-03-removing-cleanly.md): `remove` (keeps configuration files under `/etc`, `rc` state) versus `purge` (deletes them); `autoremove` for orphaned dependencies; `apt` versus the script-stable `apt-get` and `apt-cache`.
   - Mission: APT Basic Package Operations Lab
4. [Wrap-Up: Mission Debrief](./course-04-wrap-up.md)

## Why this matters

`update` instead of `upgrade` leaves a server unpatched while you believe it is current. `remove` instead of `purge` leaves old settings that a later reinstall quietly picks up. Getting these verbs right is the difference between a maintenance window that does what the ticket says and one that only looks like it did.
