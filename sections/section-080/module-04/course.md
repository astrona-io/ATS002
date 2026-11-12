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

### What is in your playground

Your playground is a training ship: one Ubuntu 24.04 virtual machine, already set up with a healthy machine with a copy of its GRUB menu to compare against.

- A healthy Ubuntu 24.04 machine with a working `/boot/grub/grub.cfg`. The setup script saves a copy at `/root/grub.cfg.original`.
- `update-grub`, `grub-mkconfig`, `grub-install` and `grub-probe`.
- No broken boot menu: a ship that really fails to boot cannot be reached over SSH. You practise the repair commands on a healthy ship, and the `grub>` prompt steps stay a worked walkthrough.

Start the playground, then open a terminal on it with `astrona ssh astro-grub-repair-bench`. The hands-on steps in the parts build on each other on this one running ship. Every command block says which shell and which rights it expects. The `grub>` prompt steps need a real console during boot, so they stay a worked walkthrough.

<!-- astrona:playground -->

## How this module is laid out

1. [Two Repairs And Reading The Symptom](./course-01-two-repairs-and-the-symptom.md): `grub-install` (the boot code) versus `update-grub` and `grub2-mkconfig` (the menu file), and telling a broken GRUB from a failing menu entry.
2. [The One-Boot Rescue From grub>](./course-02-manual-rescue-from-grub.md): `ls`, `set root=`, `linux`, `initrd` and `boot` to start the system once by hand, and why nothing about it lasts.
3. [The Durable Repair: Reinstall And Regenerate](./course-03-durable-repair.md): `grub-install` for BIOS and UEFI, `update-grub` and `grub2-mkconfig`, and checking the result with `grub-install --recheck` and `grep -c menuentry`.
   - Mission: GRUB Corruption Recovery Lab
4. [Wrap-Up: Mission Debrief](./course-04-wrap-up.md)

## Why this matters

A machine that stops at `grub>` looks dead to most people. It is not: the kernel, the files and the data are all still there. Knowing which of the two repairs you need, and running both when in doubt, turns a scary screen into a ten-minute fix.

## Verify the next boot

This exercise starts with a working SSH session and a removed GRUB menu. Repair the menu and reinstall GRUB before rebooting. On UEFI, use `x86_64-efi` for `uname -m` output `x86_64`, or `arm64-efi` for `aarch64`. Keep the existing bootloader ID `ubuntu`.

After `sudo grub-script-check /boot/grub/grub.cfg` succeeds, record `cat /proc/sys/kernel/random/boot_id`, run `sudo reboot`, reconnect and compare the boot ID. It must change. Recheck the generated menu and service state before submission. CI performs this reboot and reruns both graders. The graders inspect state; they do not run `grub-install` for you.

This is a preventive repair on the VM's real boot disk. Rescue-media boot, initramfs emergency shells and offline password recovery remain separate skills; this SSH exercise does not assess them.

<!-- curriculum-practice -->
## Practice and assessment

- [GRUB Corruption Recovery Lab](labs/lab-01/question.md): Find the boot mode and the disk that holds the root filesystem; Reinstall GRUB and regenerate grub.cfg, then prove the repair without a reboot.
- [System Disaster Recovery Integration Capstone Lab](../capstone/labs/lab-01/question.md): Restore a wiped GPT table from a backup and prove the filesystems are intact; Reinstall GRUB and regenerate grub.cfg on the running machine.
