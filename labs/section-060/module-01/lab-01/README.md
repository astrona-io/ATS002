# section-060 / module-01: RPM Low-Level Package Management Sandbox

Welcome to the Module 1 targeted practice sandbox. In this lab, you will inspect a standalone `.rpm` file before installing it, install it directly with `rpm`, answer file-ownership questions in both directions, and verify an installed package's integrity.

## Important: This Lab Runs Inside a Container

This repository's only VM image is Ubuntu 24.04 — there is no Rocky Linux/RHEL VM available. To give you a real `rpm` experience instead of a faked one, bootstrap installs Docker on the Ubuntu VM and starts a long-lived, privileged Rocky Linux 9 container named `rpmbox`. All of this lab's work happens **inside that container**, not on the Ubuntu host itself.

Get a shell inside it with:
```bash
docker exec -it rpmbox bash
```

Everything you need — the RPM to install, `rpm` itself, the RPM database — lives inside `rpmbox`. Commands run on the bare Ubuntu host will not see any of it.

## Launching the Lab
Run the following command in your terminal to boot the QEMU VM:
```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-060/module-01/lab-01
```
