# Lab 063: DNF Basic Package Operations Sandbox

Welcome to the Module 3 targeted practice sandbox. In this lab, you will run a realistic `dnf` maintenance pass: check and apply upgrades, install and remove packages, clean up orphaned dependencies, and use `dnf history` to undo and redo a transaction.

## Important: This Lab Runs Inside a Container

This repository's only VM image is Ubuntu 24.04 — there is no Rocky Linux/RHEL VM available. Bootstrap installs Docker on the Ubuntu VM and starts a long-lived, privileged Rocky Linux 9 container named `rpmbox`, with EPEL already enabled so `fail2ban` is installable. All of this lab's work happens **inside that container**, not on the Ubuntu host itself.

Get a shell inside it with:
```bash
docker exec -it rpmbox bash
```

## Launching the Lab
Run the following command in your terminal to boot the QEMU VM:
```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c labs/lab-063
```
