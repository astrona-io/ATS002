# Section 070: SUSE Package Management: Zypper

Astronaut, welcome to the SUSE supply depots. Refreshing the catalogue, searching, installing, removing and resolving dependencies work much as they do with `apt` and `dnf`. What is new is `zypper`, the quartermaster on openSUSE and SUSE Linux Enterprise, and one idea the other tools do not have in the same form: the **patch**. A patch is a reviewed safety notice from the depot that names exactly which crates (packages) to replace, kept separate from the plain stream of newer versions.

## How this section runs

Every lab here starts one training ship: an Ubuntu 24.04 virtual machine, because that is the only system image the platform offers. There is no openSUSE image to boot. Instead, each lab installs Docker on the ship and runs a long-lived container from the real `opensuse/leap:15.6` image, called `zypperbox`. A container is a sealed pod docked to the ship: its own crew and files, sharing the ship's reactor.

You do all your `zypper` work inside that pod:

```bash
docker exec -it zypperbox bash
```

Inside it, `zypper`, the RPM database and the openSUSE repositories are all real. Only the host underneath is different. The Ubuntu host itself has no `zypper`, so a `zypper` command typed there fails with "command not found". The modules in this section have no playground; you try the examples inside a running lab.

## What you will learn

By the end of this section you can:

- **Refresh, then choose patches or updates.** Refresh repository metadata, tell a raw update (`zypper list-updates`, `zypper update`) from a reviewed patch (`zypper list-patches`, `zypper patch`), and pick the one a policy asks for.
- **Install, remove and audit.** Install and remove packages with `zypper install` and `zypper remove`, and read `zypper history` as a record of what happened, not as an undo tool.
- **Research before you act.** Find a package by keyword (`zypper search`), read one package's full details without installing it (`zypper info`), find which package would supply a missing file (`zypper what-provides`), and list only installed matches (`zypper search --installed-only`).

## The modules

1. [Zypper Basic Package Operations](./module-01/course.md): refresh, updates against patches, install, remove and the history log. Mission: a conservative maintenance pass inside `zypperbox`.
2. [Zypper Package Information Lookup](./module-02/course.md): `search`, `info`, `what-provides` and installed-only search, plus the `rpm` fallback. Mission: four read-only research questions inside `zypperbox`.

## Check yourself, then the capstone

Test your understanding with the [section knowledge check](./quiz.md).

Then put both skill sets together in one maintenance window: research two requested changes, save your findings, apply only patches, install one package and remove another. Start the capstone and open a terminal on it:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-070/capstone/labs/lab-01
astrona ssh ats-002-lab-070
```

When you think you are done, send it for grading, and remove it afterwards:

```bash
astrona submit -c sections/section-070/capstone/labs/lab-01
astrona destroy ats-002-lab-070
```
