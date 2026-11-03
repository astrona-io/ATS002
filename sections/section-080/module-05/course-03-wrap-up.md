# Summary

Well flown, astronaut. You have finished every part and the mission in this module. Before you move on, look back at what you learned, check yourself, and clean up anything still running.

## What you learned

This module was about the superblock, the register of a filesystem, and repairing a filesystem whose register was destroyed.

**From [The Superblock And Checking Safely](./course-01-superblock-and-checking-safely.md):**

- The superblock describes the filesystem and sits at byte 1024 of the partition. ext4 keeps backup copies in later block groups.
- `dumpe2fs -h` and `blkid` read the superblock without changing anything.
- `fsck.ext4 -n -f` checks read-only. Never repair a mounted filesystem.

**From [Find A Backup Superblock And Repair](./course-02-backup-superblock-and-repair.md):**

- With 4096-byte blocks the backups are at 32768, 98304, 163840 and so on. With 1024-byte blocks the first is 8193.
- `mke2fs -n` lists the backups as a dry run. Without `-n` it destroys the data.
- `e2fsck -b BLOCK -y DEVICE` repairs from a backup. Afterwards, mount the filesystem and check the files.

## Your missions

You proved these skills in a graded mission, right after the part that taught the last of them:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [Filesystem Check & Repair Lab](./labs/lab-01/README.md) | Find A Backup Superblock And Repair | Repaired an ext4 filesystem from a backup superblock and showed its files survived |

If you skipped it, go back to it now. The exam asks for exactly these skills.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. Where does ext4 keep its primary superblock?</summary>

At byte 1024 of the partition. Backup copies sit in later block groups.
</details>

<details>
<summary>2. With 4096-byte blocks, where is the first backup superblock?</summary>

At block 32768. With 1024-byte blocks it is block 8193.
</details>

<details>
<summary>3. What does <code>fsck -n</code> do?</summary>

It opens the filesystem read-only and answers "no" to every repair question, so it only reports problems.
</details>

<details>
<summary>4. Why must you not run <code>mke2fs</code> without <code>-n</code> to list backups?</summary>

Without `-n` it creates a new empty filesystem and destroys the existing data.
</details>

<details>
<summary>5. Why mount the filesystem after <code>e2fsck</code> says it is clean?</summary>

A clean report says the structures are consistent. Mounting and reading the files proves the data you care about is there.
</details>

## Clean up the playground

When you are done with this module, remove the playground and any mission that is still running.

First, see what is still running:

```sh
astrona list
```

Remove the playground. The command takes its **name**, not its folder path:

```sh
astrona destroy fsck-repair-bench
```

If `astrona list` also showed a mission, remove it the same way, for example:

```sh
astrona destroy ats-002-lab-086
```

Run `astrona list` again to check that everything is gone. You can start the playground again at any time with the `astrona run` command from the module's landing page. It always starts clean, so nothing you broke carries over.

<!-- astrona:playground:destroy -->
