# section-060 / module-04: DNF Package Information Lookup Sandbox

Welcome to the Module 4 targeted practice sandbox. This lab is entirely read-only — you will research packages using `dnf search`, `dnf info`, `dnf provides`, and `dnf list installed`, without installing, removing, or upgrading anything.

## Important: This Lab Runs Inside a Container

This repository's only VM image is Ubuntu 24.04 — there is no Rocky Linux/RHEL VM available. Bootstrap installs Docker on the Ubuntu VM and starts a long-lived, privileged Rocky Linux 9 container named `rpmbox` with EPEL enabled and fresh repo metadata. All of this lab's work happens **inside that container**, not on the Ubuntu host itself.

Get a shell inside it with:
```bash
docker exec -it rpmbox bash
```

Because this lab is read-only, you'll record your research findings into a few small answer files inside the container (see `question.md` for exact paths) so your work has a concrete, checkable record.

## Launching the Lab
Run the following command in your terminal to boot the QEMU VM:
```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-060/module-04/labs/lab-01
```
