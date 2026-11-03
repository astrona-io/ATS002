# Partition Table Backup & Recovery

Astronaut, every disk carries a deck plan near its start: the partition table, a few kilobytes that say where each cargo deck begins and ends and what kind it is. Lose that plan and every filesystem on the disk becomes unreachable at once, even though the data further in is untouched. Rebuilding the boundaries from memory is slow and easy to get wrong.

The professional fix is to prepare before anything goes wrong. Keep a copy of the deck plan in another ship's safe before you run anything risky, and a mistake becomes a two-minute restore. In this module you back up a GPT partition table, destroy it on purpose on a disposable disk, restore it, and then check the filesystems inside on their own. That last step is the one people skip.

## Learning objectives

After this module you can:

- Tell the partition table apart from the filesystems inside it, and explain why restoring one proves nothing about the other.
- Identify a target disk by label, size and layout, not by a bare device name.
- Back up a GPT partition table with `sgdisk --backup`, and name the tools for older MBR disks.
- Check a partition table backup with `sgdisk --print` before you need it.
- Restore a table with `sgdisk --load-backup` after it was wiped.
- Check a restore at both levels: the partition table and the filesystems.

## Before you start

Check that you have the knowledge and the tools this module expects before you begin.

### What you should already know

- **How to use a Linux shell and `sudo`.**
- **How to mount a filesystem** and list its files.
- **That disks use one of two partition table formats:** MBR, the old format, or GPT, the modern one.

### What is in your playground

Your playground is a training ship: one Ubuntu 24.04 virtual machine, already set up with a spare GPT disk with two partitions and marker files.

- A second, 2 GB disk with the serial `lab083-vdc`. Find it at `/dev/disk/by-id/virtio-lab083-vdc`.
- On that disk, a GPT partition table with two ext4 partitions, each holding a marker file.
- `sgdisk`, `blkid` and `lsblk`.
- Your own machine stays healthy and reachable; the broken system lives on the spare disk.

Start the playground, then open a terminal on it with `astrona ssh astro-partition-table-bench`. The hands-on steps in the parts build on each other on this one running ship. Every command block says which shell and which rights it expects.

<!-- astrona:playground -->

## How this module is laid out

1. [Two Layers And The Target Disk](./course-01-two-layers-and-identifying-the-disk.md): the partition table versus the filesystems inside it, and how to be sure which disk you are about to touch.
2. [Back Up And Verify The Partition Table](./course-02-backup-and-verify.md): `sgdisk --backup` for GPT, the tools for MBR disks, and checking the backup with `sgdisk --print`.
3. [Wipe, Restore And Verify Both Layers](./course-03-simulate-restore-verify.md): `sgdisk --zap-all`, `sgdisk --load-backup`, and checking the table with `lsblk -f` and the filesystems with `fsck -n` and a test mount.
   - Mission: Partition Table Backup & Recovery Lab
4. [Wrap-Up: Mission Debrief](./course-04-wrap-up.md)

## Why this matters

Repartitioning, resizing and disk cloning are everyday jobs, and each one can damage a partition table with one wrong device name. A backup taken first costs seconds. Checking both layers afterwards is what lets you say "the disk is fine" and be right.
