# The Superblock And Checking Safely

Astronaut, before you repair anything, you need to know what is broken and what is not. This part explains the superblock, why there are copies of it, and the one rule that keeps a repair from becoming a second disaster: look first, and never repair a filesystem that is in use.

## What the superblock holds

A filesystem is more than files. At its start it keeps a description of itself: the block size, the number of blocks and inodes, how many are free, the label, the UUID, and when it was last checked. That description is the **superblock**. On ext4 it lives at byte 1024 of the partition.

In the ship picture, the superblock is the register at the entrance of a cargo deck. The crates (your files) are on the shelves further in. Destroy the register and the crew cannot find the deck's layout, but the crates are untouched.

## Why there are backups

ext4 splits the partition into **block groups**. The first group holds the primary superblock. Several other groups hold a backup copy of the superblock and of the group descriptors, which are the tables that say where each group's bitmaps and inode tables are.

With 4096-byte blocks, each group is 32768 blocks. The first backup is therefore in block 32768, and later ones are in block 98304, 163840, 229376 and so on. With 1024-byte blocks the first backup is at 8193 instead. The block size decides the numbers, so always check it.

## Look first: `dumpe2fs` and `blkid`

`dumpe2fs -h` prints the superblock without changing anything:

<!-- astrona:playground:renew -->

```bash
# shell: repair host, root
DISK=$(readlink -f /dev/disk/by-id/virtio-lab086-data001)
sudo dumpe2fs -h "${DISK}1" | head -20
```

Find `Block size`, `Block count`, `Filesystem state` and `Filesystem UUID` in the output. `blkid` reads the same data in short form:

```bash
sudo blkid "${DISK}1"
```

When the primary superblock is gone, both commands fail, which is itself a clear symptom.

## Check without changing: `fsck -n`

`fsck` is a front end that starts the right checker for the filesystem type. For ext4 that is `e2fsck`. The `-n` option opens the filesystem read-only and answers "no" to every question:

```bash
sudo fsck.ext4 -n -f "${DISK}1"
```

`-f` forces a full check even when the filesystem claims to be clean. Read the result before you decide to repair.

## The rule: never repair a mounted filesystem

Repairing writes to the filesystem's own structures. If the kernel has it mounted and is also writing to it, the two changes collide and the damage gets worse. So:

- Unmount the filesystem first: `sudo umount "${DISK}1"`.
- Or boot into a rescue environment where it was never mounted.
- The root filesystem cannot be unmounted while the system runs from it. Repair it from a rescue shell, as in module 01 of this section.

## Common pitfalls

- Running `fsck` without `-n` on a filesystem you have not looked at yet. Look first, then repair.
- Assuming the backup superblock is at 8193. That is the number for 1024-byte blocks only.
- Treating `lsblk` showing the partition as proof of a healthy filesystem. The partition table and the filesystem are separate layers.
