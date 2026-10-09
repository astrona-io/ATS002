# Compile & Install From Source

Astronaut, most of the time the quartermaster brings you finished supply crates: a package manager such as `apt` installs software that someone else already built for your system. Sometimes that is not possible. A vendor sends you an internal tool, or you need a version no depot carries. Then you get a **source tarball** instead, a kit of parts in a sealed crate.

In this module you open the crate, read its fitting plan, build the part and bolt it into the exact place the task names, with exactly the features the task asks for. Just as important, you learn to check the result on the built program, instead of trusting that your flags did what you meant.

## Learning objectives

After this module you can:

- **Extract** a `.tar.bz2`, `.tar.gz` or `.tar.xz` tarball with the right flags, and recognise a wrong-compression failure.
- **Explain** what `./configure`, `make` and `make install` each do, and why running them out of order fails.
- **Use** `./configure --help` to find the flags a task needs instead of guessing them.
- **Tell apart** install-path flags and feature switches, and choose `--bindir` over `--prefix` for an exact path.
- **Run** the build and install, using `DESTDIR` or a single `--prefix` folder when that fits.
- **Verify** the installed binary's path and its built-in features on the program itself, and rename it only when the build did not already use the required name.

## Before you start

Check that you have the knowledge and the tools this module expects.

### What you should already know

- **How to work in a Linux shell.** You can change folders with `cd`, list files with `ls` and search output with `grep`.
- **How to use `sudo`.** Some steps write into folders that belong to root, so you borrow the captain's authority for them.

You do not need any experience with compiling software. Every command block says which folder and which rights it expects.

### What you need

- An Ubuntu 24.04 machine with build tools installed (a C compiler such as `gcc`, `make`, and library headers). The `build-essential` package gives you all of them.
- Or the mission's lab machine: it already has `build-essential` and a source tarball waiting in `/tools`. The mission section gives you the exact commands.

This module has no playground. The examples use a small program (`links`), so the lesson is the build steps, not the wait.

## How this module is laid out

1. [Unpacking The Tarball And The Build Pipeline](./course-01-unpacking-and-the-build-pipeline.md): matching the `tar` compression flag to the extension, and the `./configure` → `make` → `sudo make install` steps, where each step makes what the next one needs.
2. [Discovering And Choosing Configure Flags](./course-02-discovering-and-choosing-flags.md): `./configure --help` as the only flag reference, path flags versus feature switches, and why `--bindir` beats `--prefix` for an exact path.
3. [Building, Installing And Verifying](./course-03-building-installing-verifying.md): `make` and `sudo make install`, the `DESTDIR` and `prefix=` options, and checking the path and the feature on the built program.
   - Mission: [Compile & Install From Source Lab](./labs/lab-01/question.md)
4. [Wrap-Up: Mission Debrief](./course-04-wrap-up.md)

## Why this matters

A binary in the wrong folder fails the task that needed it there, even if it works perfectly. A binary built with the wrong feature looks fine until someone relies on that feature. Checking both on the built program is what turns "I think I did it" into "I proved it", and the exam grades the machine, not your intentions.
