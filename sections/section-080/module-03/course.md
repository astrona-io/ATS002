# Partition Table Backup & Recovery

The partition table is a few kilobytes at the start of a disk describing where every partition begins, ends, and what it claims to be. Lose it and every filesystem on that disk is instantly unreachable — even though the file data further in is untouched. Reconstructing boundaries from memory is slow and error-prone; the professional fix is preventive: back the table up *before* running anything risky, so a mistake is a two-minute restore. This module backs up a GPT table, deliberately destroys it on a disposable disk, restores it, and — the step people skip — verifies the filesystems inside separately.

Three short parts; work them in order.

## How this module is organised

1. **[Part 1 — Two layers, not one, and identifying the target disk](./course-01-two-layers-and-identifying-the-disk.md)** — the partition table vs. the filesystems inside it, and positively identifying which disk you are about to operate on.
2. **[Part 2 — Back up the partition table, and verify the backup](./course-02-backup-and-verify.md)** — `sgdisk --backup` for GPT (and the `sfdisk -d` / `dd` MBR contrast), then `sgdisk --print` on the backup file to catch a bad one before you need it.
3. **[Part 3 — Simulate, restore, and verify both layers](./course-03-simulate-restore-verify.md)** — `sgdisk --zap-all` (with its re-confirm ritual), `sgdisk --load-backup`, and verifying the table layer (`lsblk -f`) and the filesystem layer (`fsck -n`, mount test) separately.

## Learning objectives

After this module you can:

- **Distinguish** the partition table from the filesystems inside it, and explain why restoring one proves nothing about the other.
- **Identify** a target disk positively by label, size, and layout — not a bare device name.
- **Back up** a GPT partition table with `sgdisk --backup`, and name the MBR equivalents.
- **Verify** a partition-table backup with `sgdisk --print` before relying on it.
- **Restore** a table with `sgdisk --load-backup` after a wipe.
- **Verify** a restore at both the table layer and the filesystem layer.

## Before you start

Assumed: a Linux shell, `sudo`, mounts, and the idea of GPT vs. MBR. Unlike the chroot modules, nothing here needs adaptation — every command runs against an ordinary secondary disk, your VM stays reachable, and the commands are exactly what you would run on a real production disk. The only lab-specific note: the destructive step targets a disposable disk you have just identified.

## Where this fits

This is the section's one preventive module — the others recover from a failure, this one keeps a failure from becoming an emergency. The "verify both layers" discipline mirrors the "prove it before you reboot" habit from the chroot modules.
