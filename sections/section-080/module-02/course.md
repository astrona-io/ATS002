# Password Reset & Single-User Recovery

Astronaut, a lost root password is a different problem from a ship that will not launch. The machine boots perfectly, every service starts and the login prompt appears on time. Only proof of identity is missing, and there is no other account that can borrow the captain's authority with `sudo`. Full rescue media would work, but it is more than you need.

The fast technique interrupts the boot menu for one launch, changes the kernel's start-up instructions for that launch only, and lands you in a root shell before any login prompt. Nothing is saved. You borrow one boot, reset the password, and the next boot is normal again.

## Learning objectives

After this module you can:

- Choose a one-boot kernel parameter edit over rescue media for a healthy but locked-out system.
- Describe where `rd.break` and `init=/bin/bash` each drop you, and the extra steps each one needs.
- Make the target root read-write and reset the password, then leave each path correctly.
- Request an SELinux relabel with `/.autorelabel` when the target enforces SELinux.
- Make a SHA-512 password hash and change only the right field of `/etc/shadow` when `passwd` cannot run.

## Before you start

Check that you have the knowledge and the tools this module expects before you begin.

### What you should already know

- **How to use a Linux shell and `sudo`.**
- **The chroot repair steps:** mount the target root, bind-mount a set of tools plus `/dev`, `/proc` and `/sys` into it, then run `chroot`.
- **That `/etc/shadow` holds the password hashes**, one line per user, with fields separated by colons.

### What you need

- This module has no playground. The `rd.break` and `init=/bin/bash` steps are worked walkthroughs only: they need a real console at the boot menu, and you cannot type into one on the training ships. Learn the keystrokes for the exam by reading them carefully.
- The mission gives you a ready-made training ship with a second, disposable disk. That disk holds a stand-in system whose root account is locked. You run the chroot and password reset steps against it, while your own ship stays healthy and reachable.

## How this module is laid out

1. [Two Doors: rd.break And init=/bin/bash](./course-01-two-doors-rd-break-and-init.md): the one-boot GRUB edit, where each parameter drops you, how to leave each path, and the SELinux relabel step.
2. [The chroot Equivalent And Editing /etc/shadow](./course-02-chroot-equivalent-and-shadow-edit.md): why a chroot reaches the same end state, and how to make a hash with `openssl passwd -6` and put it into `/etc/shadow` when `passwd` will not run.
   - Mission: Password Reset & Single-User Recovery Lab
3. [Wrap-Up: Mission Debrief](./course-03-wrap-up.md)

## Why this matters

Every administrator meets a locked-out machine sooner or later: an old server whose password nobody wrote down, or a test system where the only account was disabled. Knowing the one-boot edit turns a reinstall into a five-minute job. Knowing how `/etc/shadow` works means you can still finish the job when the usual `passwd` command is not available.
