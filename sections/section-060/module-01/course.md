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

### What you need

There is no playground for this module. The lab machines run Ubuntu 24.04, and `rpm` is not Ubuntu's package tool. So every mission in this module starts a real Rocky Linux 9 **container** named `rpmbox` on the Ubuntu machine. A container is a sealed pod docked to the ship: it has its own files and tools but shares the ship's reactor core (the kernel). Inside `rpmbox`, `rpm`, `dnf` and the RPM database are all real.

You open a shell inside it with `docker exec -it rpmbox bash`, and you run every `rpm` command there. Any Rocky Linux 9 machine works for the examples too. The mission at the end of this module gives you the exact commands to start one.

## How this module is laid out

1. [What rpm Knows and Inspecting a .rpm File](./course-01-rpm-scope-and-inspecting.md): the "one crate at a time" model, and reading a `.rpm` file's header with `rpm -qip`, `-qlp` and `-qp --requires`.
2. [Installing Directly and Ownership Queries](./course-02-installing-and-ownership.md): `rpm -ivh`, why it refuses a missing dependency, `dnf install ./file.rpm`, and the two ownership questions `-qf` and `-ql`.
3. [Verifying Integrity](./course-03-verifying-integrity.md): `rpm -V` and its nine attribute letters, the `c` configuration marker, and `--requires` against `--provides`.
   - Mission: [RPM Low-Level Package Management Lab](./labs/lab-01/question.md)
4. [Wrap-Up: Mission Debrief](./course-04-wrap-up.md)

## Why this matters

Sooner or later a vendor hands you a single `.rpm` that lives in no depot. If you install it blind, you do not know where it writes or what it needs. And when a server behaves strangely, `rpm -V` tells you in seconds whether any packaged file was changed since install. Both are everyday administrator skills, and the exam tests them directly.
