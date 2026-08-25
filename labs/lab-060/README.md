# Lab 060: RPM/DNF Package Management Capstone

Welcome to the Section 060 capstone. This lab integrates every skill from the section's five modules into one incident: a host was mid-provisioning when something killed a process overnight, and you have to sort out what actually broke versus what's just waiting on you.

## Important: This Lab Runs Inside a Container

This repository's only VM image is Ubuntu 24.04 — there is no Rocky Linux/RHEL VM available. To give you a real `rpm`/`dnf` experience instead of a faked one, bootstrap installs Docker on the Ubuntu VM and starts a long-lived, privileged Rocky Linux 9 container named `rpmbox`. All of this lab's work happens **inside that container**, not on the Ubuntu host itself.

Get a shell inside it with:
```bash
docker exec -it rpmbox bash
```

Bootstrap has already built and staged a real standalone RPM inside `rpmbox`, and — after that — genuinely corrupted its real, sqlite-backed RPM database. Neither is simulated: the staged package is a real `.rpm` built with `rpmbuild`, and the database corruption is a real, truncated `rpmdb.sqlite` file that `rpm -qa` will genuinely fail against until you repair it.

## Launching the Lab
Run the following command in your terminal to boot the QEMU VM:
```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c labs/lab-060
```
