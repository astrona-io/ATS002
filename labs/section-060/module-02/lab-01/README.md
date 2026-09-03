# section-060 / module-02: Rebuilding a Corrupted RPM Database Sandbox

Welcome to the Module 2 targeted practice sandbox. In this lab, you will diagnose real RPM database corruption, back it up safely, and rebuild it.

## Important: This Lab Runs Inside a Container

This repository's only VM image is Ubuntu 24.04 — there is no Rocky Linux/RHEL VM available. Bootstrap installs Docker on the Ubuntu VM and starts a long-lived, privileged Rocky Linux 9 container named `rpmbox`, and then genuinely corrupts its real, sqlite-backed RPM database file before you ever connect. All of this lab's work happens **inside that container**, not on the Ubuntu host itself.

Get a shell inside it with:
```bash
docker exec -it rpmbox bash
```

The corruption is real — not simulated error text. `rpm -qa` inside `rpmbox` will genuinely fail until you repair it.

## Launching the Lab
Run the following command in your terminal to boot the QEMU VM:
```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-060/module-02/lab-01
```
