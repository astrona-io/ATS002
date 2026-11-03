# Filesystem Check & Repair

Astronaut, every cargo deck keeps a register at its entrance: how big the deck is, how its shelves are laid out, and how much space is free. In a filesystem that register is the superblock. If it is destroyed, the kernel cannot read the deck at all, even though every crate inside is still on its shelf.

The good news is that a filesystem keeps spare copies of its register further inside the deck. In this module you learn to tell a damaged filesystem from a damaged disk, check one without changing it, and repair it from a backup superblock.

## Learning objectives

After this module you can:

- Explain what the superblock is, and why ext4 keeps backup copies of it.
- Check a filesystem without changing it, using `fsck -n`, and say why you never repair a mounted filesystem.
- Read a filesystem's layout with `dumpe2fs -h`.
- Find backup superblock locations without destroying anything.
- Repair an ext4 filesystem with `e2fsck -b`, and prove the files survived.

## Before you start

Check that you have the knowledge and the tools this module expects before you begin.

### What you should already know

- **How to use a Linux shell and `sudo`.**
- **How to mount a filesystem** and list its files.
- **That a disk holds a partition table and filesystems** as two separate layers.

### What is in your playground

Your playground is a training ship: one Ubuntu 24.04 virtual machine, already set up with a spare disk holding a healthy ext4 filesystem.

- A second, 1 GB disk with the serial `lab086-data001`. Find it at `/dev/disk/by-id/virtio-lab086-data001`.
- On that disk, one partition with an ext4 filesystem (label `CARGO`) holding two known files.
- `e2fsck`, `dumpe2fs`, `mke2fs`, `blkid` and `lsblk`.
- Your own machine stays healthy and reachable; the damaged system lives on the spare disk.

Start the playground, then open a terminal on it with `astrona ssh astro-fsck-repair-bench`. The hands-on steps in the parts build on each other on this one running ship. Every command block says which shell and which rights it expects.

<!-- astrona:playground -->

## How this module is laid out

1. [The Superblock And Checking Safely](./course-01-superblock-and-checking-safely.md): what the superblock holds, why backups exist, and how to check a filesystem without changing it.
2. [Find A Backup Superblock And Repair](./course-02-backup-superblock-and-repair.md): `dumpe2fs`, a safe dry run to list backups, `e2fsck -b`, and proving the files survived.
   - Mission: Filesystem Check & Repair Lab
3. [Summary](./course-03-wrap-up.md)

## Why this matters

A power cut, a bad cable or a stray `dd` can damage the first sectors of a partition. If you know the superblock is only one of several copies, the fix takes a minute. If you do not, the usual reaction is to reformat, and that loses the data.
