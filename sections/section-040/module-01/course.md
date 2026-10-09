# AppArmor Profile Enforcement & the Other MAC System: SELinux

Astronaut, every file on a Linux ship already passes one check: the owner, group and rwx bits you know as **Discretionary Access Control (DAC)**, the lock on each hatch. **Mandatory Access Control (MAC)** is a *second* gate behind it. Picture it as the ship's security chief: a policy for the whole system, which no file owner controls, that decides on its own whether a process may touch a resource. Both gates must open.

The sign that sends you here instead of to `chmod` is a denial where `ls -l` looks completely correct. That points at the second gate, which is a **Linux Security Module** in the kernel: AppArmor on Debian, Ubuntu and SUSE, SELinux on the RHEL family.

This module teaches **AppArmor hands-on**: your playground and the missions run Ubuntu 24.04, where AppArmor is the live, enforcing security module. It teaches **SELinux as a worked walkthrough**. The LFCS objective names SELinux and RHEL-family exam machines run it, but the Ubuntu training ship cannot run SELinux, so there is nothing to practise it on here. The SELinux parts say so plainly.

## Learning objectives

After this module you can:

- **Recognise** the "correct DAC, still denied" sign and name which MAC system a given distribution enforces.
- **Explain** the difference between AppArmor's path matching and SELinux's label matching, and predict what happens to each when a file moves to a new path.
- **Run** `aa-status` and state, for each profile, whether it is loaded and whether it is in `enforce` or `complain` mode.
- **Read** an AppArmor profile and tell apart path rules, access modes (`r`, `w`, `ix`, `rix`, `px`), `#include` lines and `capability` lines.
- **Find** an AppArmor denial in `journalctl -k` and pick out the `profile=`, `operation=`, `name=` and `denied_mask=` fields.
- **Fix** a path denial by editing `/etc/apparmor.d/local/` (or with `aa-logprof`), reload it with `apparmor_parser -r`, and confirm it really enforces and was not left in `complain`.
- **Read** an SELinux AVC denial's `scontext` and `tcontext`, and give the lasting fix (`semanage fcontext -a` plus `restorecon`), and explain why `chcon` alone does not survive a relabel.
- **Choose** between file-context policy and port-type policy (`semanage port`) for a given SELinux denial.

## Before you start

Check that you have the knowledge this module expects, and get to know the playground you will work on.

### What you should already know

- **Linux file permissions:** `ls -l`, owner, group and mode bits.
- **Running commands with `sudo`** and reading a plain-text configuration file.
- **What a service is:** a long-running program that `systemd`, the ship's duty officer, starts and watches.

You need no earlier AppArmor or SELinux experience.

### What is in your playground

Your playground is a training ship: one Ubuntu 24.04 virtual machine with AppArmor as the live security module and the `apparmor-utils` tools installed. It runs a demo service, **`appservice`**, that writes a heartbeat line to `/srv/applogs/app.log` every few seconds.

The service sits behind a profile that is too strict on purpose. The profile is loaded in **enforce** mode and only allows the service's *old* log folder. The DAC permissions on `/srv/applogs` are already correct, so a fresh `apparmor="DENIED"` record is always waiting in the kernel log for you to find.

Start the playground, then open a terminal on it with `astrona ssh astro-apparmor-mac-enforcement`. The hands-on steps in the AppArmor parts build on each other on this one running ship: first you find the denial, then you fix it. The SELinux parts have no hands-on steps. Every command block says which shell and which rights it expects.

<!-- astrona:playground -->

## The parts of this module

1. [Two Gates: DAC, MAC And Which System You Are On](./course-01-two-gates-dac-mac-and-which-system.md): the DAC then MAC check order, the "correct permissions, still denied" sign, which distribution runs which system, and path versus label.
2. [AppArmor Profiles And Modes](./course-02-apparmor-profiles-and-modes.md): `aa-status`, how a profile file is built, the `local/` override, and enforce versus complain mode.
3. [Read An AppArmor Denial](./course-03-apparmor-reading-a-denial.md): finding `apparmor="DENIED"` in `journalctl -k` and reading it field by field.
4. [Fix An AppArmor Denial And Prove It](./course-04-apparmor-fixing-a-denial.md): adding the rule in `/etc/apparmor.d/local/` or with `aa-logprof`, reloading with `apparmor_parser -r`, and proving the profile really enforces.
   - Mission: [AppArmor Profile Enforcement Lab](./labs/lab-01/question.md)
   - Mission: [AppArmor: Repair a Read Denial Lab](./labs/lab-02/question.md)
5. [SELinux Labels And AVC Denials](./course-05-selinux-labels-and-avc-denials.md): the `user:role:type:level` context, the three modes, and reading an AVC denial's `scontext` and `tcontext` (walkthrough, no hands-on steps).
6. [Persistent SELinux Fixes And The AppArmor Contrast](./course-06-selinux-persistent-fixes-and-contrast.md): why `chcon` does not survive a relabel, the `semanage fcontext -a` and `restorecon -Rv` pair, port types, and both systems side by side (walkthrough, no hands-on steps).
7. [Wrap-Up: Mission Debrief](./course-07-wrap-up.md)

## Why this matters

MAC turns a "the permissions are clearly fine, why is this broken?" incident from a mystery into a two-minute diagnosis. It shows up whenever a service is moved to a path or port it did not use before: a moved web folder, a moved log folder, a new listening port. That is exactly the shape of the missions in this module. Keep the path-versus-label difference in mind: it tells you which set of tools the machine in front of you needs.
