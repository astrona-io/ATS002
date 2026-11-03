# Find A Backup Superblock And Repair

Astronaut, the primary register is gone but the spare copies are intact. This part shows how to list where the copies are without changing anything, how to repair from one of them, and how to prove that your crates survived.

## Recognise the damage

A filesystem with a destroyed primary superblock cannot be mounted:

<!-- astrona:playground:renew -->

```bash
# shell: repair host, root
DISK=$(readlink -f /dev/disk/by-id/virtio-lab086-data001)
sudo mount "${DISK}1" /mnt
sudo dumpe2fs -h "${DISK}1"
```

The mount mentions a wrong filesystem type or a bad superblock, and `dumpe2fs` cannot find a valid one. The exact wording differs between versions. In the playground the filesystem starts healthy, so you cause this damage yourself first. The overview page has the command for it.

## List the backup superblocks, safely

`mke2fs` creates filesystems, but its `-n` option makes it a dry run: it prints what it would do and writes nothing.

```bash
sudo mke2fs -n -b 4096 "${DISK}1"
```

Look for the line `Superblock backups stored on blocks:` and the numbers after it. Give the same `-b` value the filesystem was created with, because the block size decides the numbers.

**Warning:** leave out `-n` and this command creates a new, empty filesystem on the partition and destroys your data. If you are not sure, skip this step: with 4096-byte blocks the first backup is always block 32768.

## Repair with `e2fsck -b`

Tell `e2fsck` to read the filesystem description from a backup copy:

```bash
sudo e2fsck -b 32768 -y "${DISK}1"
```

- `-b 32768` is the backup superblock to use.
- `-y` answers yes to every repair question. Use it when you have already looked at the damage and want an unattended run.

Expect many lines about wrong free block counts, free inode counts and group descriptors. Those summary numbers are only kept current in the primary copy, so the backup has older values and `e2fsck` corrects them. At the end it writes a new primary superblock. Run it again to see a clean result:

```bash
sudo fsck.ext4 -n -f "${DISK}1"
```

`e2fsck` normally tries the backup superblocks on its own when the primary one is unreadable. Giving `-b` yourself is still the exam answer, because it is explicit and works when you want to choose which copy to use.

## Prove the files survived

A clean check is not the finish line. Mount it and look at the files:

```bash
sudo mount "${DISK}1" /mnt
ls -R /mnt
sudo umount /mnt
```

Files that lost their directory entry end up in `lost+found` at the top of the filesystem, named after their inode number. If it is empty, nothing was orphaned.

## Common pitfalls

- Running `mke2fs` without `-n`.
- Using a backup number for the wrong block size.
- Repairing while the filesystem is mounted.
- Calling the job done after `e2fsck` without mounting the filesystem to check the data.

## Your mission: Filesystem Check & Repair Lab

You can now read a superblock, list backups safely, repair from one and check the data. The mission gives you a spare disk whose primary superblock has been wiped, with two files on it that must survive.

The mission runs on its own training ship. Your playground cannot be paused, so remove it first. It always starts clean, so you lose nothing you need:

```sh
astrona destroy fsck-repair-bench
```

Then start the mission and open a terminal on it:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-080/module-05/labs/lab-01
astrona ssh ats-002-lab-086
```

Read the task in [`question.md`](./labs/lab-01/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-080/module-05/labs/lab-01
```

When the mission is done, remove it and start your playground again:

```sh
astrona destroy ats-002-lab-086
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-080/module-05/playground
```
