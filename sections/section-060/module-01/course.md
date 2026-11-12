# RPM Low-Level Package Management

Astronaut, on a Red Hat family ship (Rocky Linux, RHEL, Fedora) every piece of software arrives as a **package**: a supply crate with a parts list, a version and a list of the crates it needs. When `dnf install` finishes, a quieter tool did the real work. `rpm` unpacked the files and wrote them into a local database under `/var/lib/rpm`.

`dnf` is the quartermaster: it talks to supply depots and orders every crate a package needs. `rpm` is the loading crew: it unpacks the one crate it is handed and knows nothing about depots. Most days you never call `rpm` yourself. You need it when someone hands you a single `.rpm` file, or when you must check whether an installed package's files have changed since install. This module works at that lower level.

## Learning objectives

After this module you can:

- Say what `rpm` works on, and use `-p` correctly to switch between a `.rpm` file and the installed database.
- Inspect a `.rpm` file's details, file list and declared needs without changing the system.
- Install a single `.rpm` file, and explain why `rpm -ivh` refuses a missing dependency while `dnf install ./file.rpm` does not.
- Find the package that owns a file (`rpm -qf`) and the files that belong to a package (`rpm -ql`).
- Read `rpm -V` output, its per-attribute letters and its file-type marker, and tell a harmless configuration edit from a real integrity problem.
- Explain how `--provides` capabilities drive dependency resolution, separate from package names.

## Before you start

Check that you have the knowledge and the tools this module expects.

### What you should already know

- **How to use a Linux shell.** You can type commands, read their output and use `sudo`.
- **What a package is.** A file that holds a program, its files and a list of what it needs. On Debian and Ubuntu that is a `.deb` handled by `dpkg`; on the Red Hat family it is a `.rpm` handled by `rpm`.

### What is in your playground

Your playground is a training ship: one Ubuntu 24.04 virtual machine. That machine has no tools of this package family, so the playground runs a real Rocky Linux 9 **container** named `rpmbox` on it. A container is a sealed pod docked to the ship: it has its own files and tools but shares the ship's reactor core (the kernel). Inside it, the package tools and the package database are all real.

- A small internal package, `logship-agent` version `2.1.0-1`, built inside `rpmbox`. The file is `/home/candidate/downloads/logship-agent-2.1.0-1.x86_64.rpm` inside the container, and the package is not installed yet.
- The `rpmbuild` tools, which built it.

Start the playground, then open a terminal on it with `astrona ssh astro-rpm-low-level`. Step into the pod with `docker exec -it rpmbox bash` and run every package command in that shell. If Docker refuses with a permission error, put `sudo` in front. It is already set up with a standalone `.rpm` file and a real RPM database.

<!-- astrona:playground -->

## How this module is laid out

1. [What rpm Knows and Inspecting a .rpm File](./course-01-rpm-scope-and-inspecting.md): the "one crate at a time" model, and reading a `.rpm` file's header with `rpm -qip`, `-qlp` and `-qp --requires`.
2. [Installing Directly and Ownership Queries](./course-02-installing-and-ownership.md): `rpm -ivh`, why it refuses a missing dependency, `dnf install ./file.rpm`, and the two ownership questions `-qf` and `-ql`.
3. [Verifying Integrity](./course-03-verifying-integrity.md): `rpm -V` and its nine attribute letters, the `c` configuration marker, and `--requires` against `--provides`.
   - Mission: [RPM Low-Level Package Management Lab](./labs/lab-01/question.md)
4. [Wrap-Up: Mission Debrief](./course-04-wrap-up.md)

## Why this matters

Sooner or later a vendor hands you a single `.rpm` that lives in no depot. If you install it blind, you do not know where it writes or what it needs. And when a server behaves strangely, `rpm -V` tells you in seconds whether any packaged file was changed since install. Both are everyday administrator skills, and the exam tests them directly.

<!-- curriculum-practice -->
## Practice and assessment

- [RPM Low-Level Package Management Lab](labs/lab-01/question.md): Inspect an .rpm file's metadata and file list before installing it; Install it with rpm and query ownership, file lists, requires and provides; Verify the installed files against the RPM database.
- [RPM/DNF Package Management Capstone Lab](../capstone/labs/lab-01/question.md): Diagnose and repair a corrupted RPM database with a backup first; Inspect, install and verify a standalone .rpm file; Install a package group and prove the system is consistent with dnf check.
