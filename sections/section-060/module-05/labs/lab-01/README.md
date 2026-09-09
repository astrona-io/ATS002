# section-060 / module-05: DNF Package Groups Sandbox

Welcome to the Module 5 targeted practice sandbox. In this lab, you will discover what package groups a system's repositories actually publish, inspect a specific group's real mandatory/default/optional membership before installing it, install and confirm it, then remove it cleanly as a unit — and reason precisely about which packages a group removal does and doesn't touch.

## Important: This Lab Runs Inside a Container

This repository's only VM image is Ubuntu 24.04 — there is no Rocky Linux/RHEL VM available. To give you a real `dnf` group experience instead of a faked one, bootstrap installs Docker on the Ubuntu VM and starts a long-lived, privileged Rocky Linux 9 container named `rpmbox`. All of this lab's work happens **inside that container**, not on the Ubuntu host itself.

Get a shell inside it with:
```bash
docker exec -it rpmbox bash
```

Bootstrap has also pre-installed `automake` inside `rpmbox` on its own, independently of any group — before you ever touch `"Development Tools"`. That's deliberate: it's what lets you observe, for real, exactly which packages a later `dnf group remove` does and doesn't remove.

## Launching the Lab
Run the following command in your terminal to boot the QEMU VM:
```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-060/module-05/labs/lab-01
```
