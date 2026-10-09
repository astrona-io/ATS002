# APT Package Groups & Bulk Operations

Astronaut, real package work rarely happens one crate at a time. A build toolchain arrives as a metapackage plus a few companions, installed together. A whole family of modules, such as every `php8.x-*` package or every `linux-image-*` package, has to be found and handled as one set. And when the members of a family really depend on each other, protecting only *some* of them from an upgrade can be worse than protecting none.

This module is about working on packages in groups. You install several in one transaction, find a family by its naming pattern, and hold the whole matched set in one step you can check.

## Learning objectives

After this module you can:

- Install several related packages as one transaction, and explain why that beats separate calls.
- Match a package family by its naming pattern, escaping the literal dot and anchoring the match to the start of the name.
- Turn `apt list` output into bare package names with `cut -d/ -f1`.
- Hold a whole matched set at once by piping the names through `xargs` into `apt-mark hold`.
- Explain why a partial hold on a family that depends on itself can be worse than no hold.
- Check the result with `apt-mark showhold` instead of trusting the pipeline's exit code.

## Before you start

Check that you have the knowledge and the tools this module expects before you begin.

### What you should already know

- **How to run a command with `sudo`.** Installing and holding packages needs the captain's authority.
- **What a hold is.** `apt-mark hold <name>` puts a "do not replace" tag on one installed package, and `apt-mark showhold` lists the tagged ones.
- **`apt list --installed` and basic `grep` patterns.** The parts explain the two pattern details that matter here.

### What you need

- A terminal on an Ubuntu 24.04 machine where you may install packages.
- Or a running lab machine: start the mission with `astrona run` and open a terminal on it with `astrona ssh <lab name>`. The mission gives you the exact commands.

## How this module is laid out

1. [One Transaction And Finding A Family](./course-01-one-transaction-and-finding-a-family.md): giving several packages to one `apt install` so their dependencies resolve as one set, and matching a family with `grep -E '^prefix'` (the `-E` and `^` details) and `cut -d/ -f1`.
2. [Bulk Actions Across A Matched Set](./course-02-bulk-actions-across-a-set.md): `xargs` into one `apt-mark hold`, why a partial hold on a family that depends on itself is worse than no hold, and checking with `apt-mark showhold`.
   - Mission: APT Package Groups & Bulk Operations Lab
3. [Wrap-Up: Mission Debrief](./course-03-wrap-up.md)

## Why this matters

A hold that covers four of six related packages looks safe and is not. The next upgrade moves the other two, and the family no longer matches. Finding the whole set by pattern, acting on it in one step and checking the result is how you protect a group for real.
