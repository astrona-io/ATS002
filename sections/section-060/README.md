# Section 060: RPM/DNF Package Management: rpm, dnf & Package Groups

Welcome, astronaut, to the Red Hat family supply runs. Every Rocky Linux, RHEL or Fedora server depends on two tools to decide what software is on board and which exact version runs: `rpm` and `dnf`. Used well, they keep a maintenance window predictable. Used blindly, they quietly break things.

In this section you work through the RPM family's package tools from the bottom up. You start with `rpm`, the loading crew that unpacks one package and records it in the RPM database. You then move up to `dnf`, the quartermaster that fetches packages from repositories with everything they depend on. You finish with `dnf` package groups: ready-made bundles of packages that you install and remove as one unit.

## How the labs run

The lab machines in this course run Ubuntu 24.04, and Ubuntu uses `dpkg` and `apt`, not `rpm` and `dnf`. Instead of faking the output, every lab in this section installs Docker on the Ubuntu machine and starts a long-lived Rocky Linux 9 **container** named `rpmbox`. A container is a sealed pod docked to the ship: it has its own files, tools and RPM database, and shares the ship's kernel.

Everything inside `rpmbox` is real: a real Rocky Linux 9 system, a real `rpm`, a real `dnf` and a real RPM database. The only unusual part is how you reach it. You open a terminal on the lab machine with `astrona ssh`, then open a shell inside the container with `docker exec -it rpmbox bash`.

## What you will learn

By the end of this section you can:

- **Work with single packages using `rpm`.** Inspect and install a standalone `.rpm` file, answer which package owns which file, and verify an installed package against its install-time record.
- **Repair the RPM database.** Recognise real database corruption on a `sqlite`-based RPM database, tell it apart from a dependency problem or a full disk, back it up and rebuild it.
- **Run the daily `dnf` loop.** Check and apply upgrades, install and remove packages, clean up leftovers, and undo or redo a whole transaction with `dnf history`.
- **Research packages before acting.** Search by keyword, read full package details and find which package provides a missing file or command, all without installing anything.
- **Use package groups.** Find, inspect, install and remove a repository-published group, and predict exactly which packages a group removal takes.

## The modules

Work through the modules in order. Each one ends with at least one graded mission on a fresh lab machine.

1. [RPM Low-Level Package Management](./module-01/course.md): inspecting and installing a `.rpm` file, ownership queries and `rpm -V`.
2. [Rebuilding a Corrupted RPM Database](./module-02/course.md): recognising corruption and its look-alikes, backing up and rebuilding.
3. [DNF Basic Package Operations](./module-03/course.md): the everyday `dnf` loop and `dnf history undo`.
4. [DNF Package Information Lookup](./module-04/course.md): `dnf search`, `dnf info`, `dnf provides`, and when to trust `rpm` instead.
5. [DNF Package Groups](./module-05/course.md): group tiers, installing a group and what a group removal leaves behind.

After the modules, test yourself with the [section knowledge check](./quiz.md).

## The capstone

The capstone puts the whole section into one incident. A ship was halfway through being set up when a process was killed overnight. You diagnose and repair a really damaged RPM database, inspect and install a standalone package that was waiting, and then find, inspect and install a full `dnf` package group to finish setting the ship up as a build server.

Start it and open a terminal on it:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-060/capstone/labs/lab-01
astrona ssh ats-002-lab-060
```

Read the task in [`question.md`](./capstone/labs/lab-01/question.md). When you think you are done, send it for grading, then remove it:

```bash
astrona submit -c sections/section-060/capstone/labs/lab-01
astrona destroy ats-002-lab-060
```
