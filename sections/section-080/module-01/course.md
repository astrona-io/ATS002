# Root-Filesystem Repair via chroot

A single bad line in `/etc/fstab` is one of the fastest ways to turn a running server into one that will not boot: systemd blocks on the mount that can never succeed and drops to an emergency shell. Nothing is damaged — every file is where it was — but the one piece of config that says "mount this, here" is wrong. Recovering does not involve reinstalling anything. It means getting *into* the broken system's filesystem from outside, running its own tools against its own config, fixing the one line, and proving the fix before you reboot. That is a **chroot repair**, and it is core muscle memory for this domain.

Three short parts; work them in order.

## How this module is organised

1. **[Part 1 — Why a bad fstab stops the boot, and how to reach a shell](./course-01-why-it-wont-boot-and-reaching-a-shell.md)** — the systemd mount-failure mechanism and `emergency.target`, and reaching a shell via GRUB `systemd.unit=rescue.target` or live media.
2. **[Part 2 — Mount the broken root, and get the tools in](./course-02-mount-and-get-tools-in.md)** — identifying the partition with `lsblk -f`, mounting it, bind-mounting `/usr` `/bin` `/sbin` `/lib` for a working userland, and the `/dev` `/proc` `/sys` binds that guides skip.
3. **[Part 3 — chroot in, fix, prove, unmount](./course-03-chroot-fix-prove-unmount.md)** — `chroot`, cross-checking the bad UUID against `blkid`, the `sed` fix, `mount -a; echo $?` as the pre-reboot proof, and reverse-order unmounting.

## Learning objectives

After this module you can:

- **Explain** why a bad `/etc/fstab` entry blocks the boot rather than being skipped.
- **Reach** a shell on a system that will not boot, via the bootloader or rescue media.
- **Identify** the target root partition without guessing a device name.
- **Assemble** a working chroot: bind-mount a userland plus `/dev`, `/proc`, `/sys`, and explain what fails without the last three.
- **Correct** a bad fstab line by cross-referencing `blkid`, and create any missing mount point.
- **Prove** the fix with `mount -a` inside the chroot before rebooting, and unmount cleanly.

## Before you start

Assumed: a Linux shell, `sudo`, mounts and UUIDs, and basic `sed`. **How the lab runs:** the grading harness reaches your VM only over SSH, so it cannot drive an interactive GRUB menu or recover an unbootable VM. The lab therefore attaches a second, disposable disk holding a stand-in "broken system" (its own `/etc/fstab`, its own tree); your VM stays healthy and reachable, and you aim the identical repair sequence at that disk. Every mechanical step — identify partition, bind-mount, chroot, edit, `mount -a`, unmount — is exactly the real thing; only the target disk differs.

## Where this fits

This module builds the chroot mechanic the rest of the section reuses — the password-reset module aims the same sequence at a locked-out account, and the GRUB module aims it at a broken bootloader. "Prove it inside the chroot before you reboot" is the habit the section capstone tests.
