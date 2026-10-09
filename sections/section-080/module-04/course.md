# GRUB Corruption Recovery

Astronaut, sometimes the trouble starts before the kernel even wakes up. GRUB is the ship's launch computer, and `grub.cfg` is its launch checklist. When GRUB itself is broken, the machine drops straight to a bare `grub>` prompt: the launch computer with no checklist, waiting for typed orders. Or a menu appears, but the file behind it is missing or cannot be read.

Rebuilding the checklist alone is not always enough. GRUB's own installed boot code, and its ability to find a checklist at all, may both be broken. The full repair reinstalls GRUB on the disk and then writes a fresh checklist.

## Learning objectives

After this module you can:

- Tell `grub-install` apart from `update-grub` and `grub2-mkconfig` by what each one writes and what each one needs.
- Read a boot symptom to tell a broken GRUB from a problem further along.
- Build a one-time boot by hand from a bare `grub>` prompt, and explain why it is not a fix.
- Reinstall GRUB with the right BIOS or UEFI command after checking the firmware type.
- Regenerate the GRUB configuration and check the repair without a reboot.

## Before you start

Check that you have the knowledge and the tools this module expects before you begin.

### What you should already know

- **How to use a Linux shell and `sudo`.**
- **The chroot repair steps:** mount the target root, bind-mount `/dev`, `/proc` and `/sys` into it, then run `chroot`. You need them when the broken system cannot boot at all.
- **The two firmware types:** older BIOS machines and modern UEFI machines start a bootloader in different ways.

### What you need

- This module has no playground. The `grub>` prompt steps are a worked walkthrough only: they need a real console during boot, which you cannot reach on the training ships.
- The mission gives you a ready-made training ship whose `/boot/grub/grub.cfg` has been removed. Its current boot already finished, so SSH keeps working; only the next reboot would fail. You run the real repair before that reboot happens.

## How this module is laid out

1. [Two Repairs And Reading The Symptom](./course-01-two-repairs-and-the-symptom.md): `grub-install` (the boot code) versus `update-grub` and `grub2-mkconfig` (the menu file), and telling a broken GRUB from a failing menu entry.
2. [The One-Boot Rescue From grub>](./course-02-manual-rescue-from-grub.md): `ls`, `set root=`, `linux`, `initrd` and `boot` to start the system once by hand, and why nothing about it lasts.
3. [The Durable Repair: Reinstall And Regenerate](./course-03-durable-repair.md): `grub-install` for BIOS and UEFI, `update-grub` and `grub2-mkconfig`, and checking the result with `grub-install --recheck` and `grep -c menuentry`.
   - Mission: GRUB Corruption Recovery Lab
4. [Wrap-Up: Mission Debrief](./course-04-wrap-up.md)

## Why this matters

A machine that stops at `grub>` looks dead to most people. It is not: the kernel, the files and the data are all still there. Knowing which of the two repairs you need, and running both when in doubt, turns a scary screen into a ten-minute fix.
