# GRUB Corruption Recovery

A bad `/etc/fstab` line (Module 1) leaves the bootloader working. This module covers GRUB itself being broken: the machine drops straight to a bare `grub>` rescue prompt, or a menu appears but its config file is missing or unreadable. Regenerating a config — all Module 1 needed — is not the whole fix here. GRUB's own installed boot code, and its ability to find a config at all, may both be broken, which means genuinely reinstalling GRUB to the disk, not just rebuilding a config on top of it.

Three short parts; work them in order.

## How this module is organised

1. **[Part 1 — Two repairs, easy to confuse, and reading the symptom](./course-01-two-repairs-and-the-symptom.md)** — `grub-install` (boot-sector/EFI code) vs `update-grub` / `grub2-mkconfig` (menu config), and telling a broken-GRUB symptom from a failing menu entry.
2. **[Part 2 — The one-boot manual rescue from `grub>`](./course-02-manual-rescue-from-grub.md)** — `ls` / `set root=` / `linux` / `initrd` / `boot` to hand-assemble a single boot, and why nothing about it persists.
3. **[Part 3 — The durable repair: reinstall and regenerate](./course-03-durable-repair.md)** — `grub-install` (BIOS vs UEFI forms), `update-grub` / `grub2-mkconfig`, and verifying with `grub-install --recheck` and `grep -c menuentry`.

## Learning objectives

After this module you can:

- **Distinguish** `grub-install` from `update-grub` / `grub2-mkconfig` by what each writes and assumes.
- **Read** a boot symptom to tell broken GRUB from a problem further along.
- **Hand-assemble** a one-time boot from a bare `grub>` prompt, and explain why it is not a fix.
- **Reinstall** GRUB with the correct BIOS or UEFI invocation after confirming the firmware type.
- **Regenerate** the GRUB config and verify the repair without a reboot.

## Before you start

Assumed: Module 1's chroot mechanic, a Linux shell, `sudo`, and BIOS vs UEFI. **How the lab runs:** the SSH-only harness cannot type at a `grub>` prompt or recover an unbootable VM, so bootstrap removes this VM's `grub.cfg` but leaves the running kernel and GRUB's boot code intact — the current boot already succeeded, SSH stays up, and the next reboot would fail. Framing is "fix it before that reboot". Know the Part 2 console sequence for the exam; the lab drills Parts 1 and 3 in full, running both `grub-install` and `update-grub` as a real full repair would.

## Where this fits

This is the section's deepest boot-layer repair — Module 1 fixed a mount instruction handed to systemd, this fixes the bootloader that runs before systemd exists. Running both repair tools every time, even when only one was strictly needed, is the habit the section capstone rewards.
