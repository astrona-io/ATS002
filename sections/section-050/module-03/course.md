# Chapter 3: APT Basic Package Operations

Most package management is one ordinary loop: find what is new, apply it, install one more thing, retire something you no longer need. Mechanically it is simple — but it is also the biggest source of avoidable mistakes in this domain, almost entirely because pairs of verbs sound alike and do different things: `update` vs `upgrade`, `remove` vs `purge`. This module walks the loop the way you would on a real maintenance window, with the emphasis on those distinctions.

Three short parts; work them in order.

## How this module is organised

1. **[Part 1 — `apt update` is not `apt upgrade`](./course-01-update-is-not-upgrade.md)** — `apt update` re-downloads the package index and changes nothing installed; why a stale index breaks later commands; `apt list --upgradable` as the read-only preview.
2. **[Part 2 — Applying upgrades, and installing](./course-02-applying-upgrades-and-installing.md)** — `apt upgrade` moves versions but never adds/removes packages, which produces the "kept back" list; `apt full-upgrade` when a set change is confirmed safe; `apt install`.
3. **[Part 3 — Removing cleanly](./course-03-removing-cleanly.md)** — `remove` (keeps `/etc` conffiles, `rc` state) vs `purge` (deletes them); `autoremove` for orphaned dependencies; `apt` vs the script-stable `apt-get` / `apt-cache`.

## Learning objectives

After this module you can:

- **State** what `apt update` changes about installed packages (nothing) and why running it first matters.
- **Preview** pending upgrades with `apt list --upgradable`.
- **Explain** why a package is "kept back" and choose `apt full-upgrade` deliberately when it is.
- **Install** a package and its dependencies in one transaction.
- **Choose** between `apt remove` and `apt purge` from a task's wording, and recognise the `rc` state.
- **Clean up** orphaned dependencies with `apt autoremove` as a separate step.
- **Choose** `apt` for interactive use and `apt-get` / `apt-cache` for scripts.

## Before you start

Assumed: a Linux shell, `sudo`, and Modules 1–2 (repositories, `dpkg` status codes). Every command block states the shell and privilege it assumes.

## Where this fits

This is the everyday loop the rest of the section supports — Module 4 is the read-only research you do *before* running these verbs, Module 5 is running them across a whole family of packages at once. The section capstone runs this loop under time pressure with a wording cue that hinges on `remove` vs `purge`.
