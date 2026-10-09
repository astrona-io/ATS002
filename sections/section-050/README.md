# Debian Package Management: Repositories, dpkg & APT

Welcome to the supply runs, astronaut. Every Debian or Ubuntu server depends on its package manager. It decides which software is on board, which exact version runs, which depot it came from, and whether a routine maintenance window keeps the system as predictable as it was yesterday or quietly breaks it.

In this section you work through the Debian packaging stack. A **package** is a supply crate, a **repository** is the depot that ships it, `apt` is the quartermaster who orders crates and everything they need, and `dpkg` is the loading crew that unpacks one crate at a time. You start with trusting a vendor's depot, go down to `dpkg`, then work up through the daily `apt` loop, read-only research and bulk actions on whole package families.

Every exercise runs on an Ubuntu 24.04 virtual machine with the real `apt` and `dpkg` tools. The labs build and serve their own signed repositories and `.deb` files on `127.0.0.1`, so nothing depends on an outside vendor.

## What you will be able to do

By the end of this section you can:

- **Trust a third-party repository the modern way.** Add a vendor's repository with a dedicated keyring and `signed-by=`, install an exact version from it, and hold or pin that version.
- **Work at the `dpkg` level.** Inspect, install and question a standalone `.deb` file, and recover a package left half-configured.
- **Run the daily `apt` maintenance loop.** Use `apt update`, `apt upgrade` and `apt full-upgrade`, `apt install`, `apt remove` versus `apt purge`, and `apt autoremove` in the right order.
- **Research before you act.** Search by keyword, read full metadata, and confirm the installed and candidate versions and their source repository, all read-only.
- **Act on package groups.** Install a toolchain as one transaction, find a package family by naming pattern, and hold the whole family together.

## The modules

Each module ends with one or more graded missions that run on their own training ship. The module pages give the commands to start them.

1. [Third-Party Repositories & Package Pinning](./module-01/course.md): scoped trust with keyrings and `signed-by`, adding and checking a repository, installing an exact version, holding it, and APT pinning.
2. [dpkg Low-Level Package Management](./module-02/course.md): inspecting a `.deb`, installing it directly, ownership questions in both directions, status codes and recovering an interrupted package.
3. [APT Basic Package Operations](./module-03/course.md): `update` versus `upgrade`, kept-back packages and `full-upgrade`, installing, and removing cleanly with `purge` and `autoremove`.
4. [APT Package Information Lookup](./module-04/course.md): `apt search`, `apt list`, `apt show`, `apt-cache policy` and `dpkg -s` for read-only research.
5. [APT Package Groups & Bulk Operations](./module-05/course.md): one-transaction installs, finding a family by pattern and holding the whole set.

## Check your knowledge

When you have finished the modules, test your understanding with the [knowledge check quiz](./quiz.md).

## The capstone mission: New App Server Onboarding

The capstone joins every skill from this section on one freshly built application server. You install a toolchain in one transaction, trust a vendor repository and install and hold its exact build, recover a package stuck in the middle of an install, hold a whole package family, and research a package without installing it. Read the task in [`question.md`](./capstone/labs/lab-01/question.md).

Start the capstone and open a terminal on it:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-050/capstone/labs/lab-01
astrona ssh ats-002-lab-050
```

When you think you are done, send it for grading:

```bash
astrona submit -c sections/section-050/capstone/labs/lab-01
```

When the mission is done, remove it:

```bash
astrona destroy ats-002-lab-050
```
