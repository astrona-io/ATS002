# Wrap-Up: Mission Debrief

Well flown, astronaut. You have finished every part and the mission in this module. Before you move on, look back at what you learned, check yourself, and clean up anything still running.

## What you learned

This module was about keeping a copy of a disk's deck plan, the partition table, and proving a disk is really usable after a restore.

**From [Two Layers And The Target Disk](./course-01-two-layers-and-identifying-the-disk.md):**

- The partition table holds only boundaries and types. The filesystems inside the partitions are a separate layer.
- Restoring the table proves nothing about the filesystems inside it.
- Identify the target disk by size, labels and layout with `lsblk -f`, and confirm it is not `/`. Repeat the check before anything destructive.

**From [Back Up And Verify The Partition Table](./course-02-backup-and-verify.md):**

- `sgdisk --backup=FILE /dev/DISK` saves the GPT headers and partition entries, with no file data.
- For MBR disks, `sfdisk -d` gives a text dump; a raw `dd` of the first 512 bytes is not enough for GPT.
- Check the backup at once with `sgdisk --print FILE` and its file size, and keep it off the disk you are risking.

**From [Wipe, Restore And Verify Both Layers](./course-03-simulate-restore-verify.md):**

- `sgdisk --zap-all` wipes the table; `sgdisk --load-backup=FILE` writes it back.
- Check the table layer with `lsblk -f`.
- Check the filesystem layer with `fsck -n` and a test mount that shows the expected files.

## Your missions

You proved these skills in a graded mission, right after the part that taught the last of them:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [Partition Table Backup & Recovery Lab](./labs/lab-01/README.md) | Wipe, Restore And Verify Both Layers | Backed up a GPT table, restored it after a wipe, and showed both filesystems and their files survived |

If you skipped it, go back to it now. The exam asks for exactly these skills.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. After a restore, <code>lsblk</code> shows both partitions again. Is the disk proven healthy?</summary>

No. That only proves the table layer. Run `fsck -n` on each partition and mount it to check that the files are there.
</details>

<details>
<summary>2. Does <code>sgdisk --backup</code> save the files inside the partitions?</summary>

No. It saves only the partition table: the headers and the partition entries. Backing up the data is a separate job.
</details>

<details>
<summary>3. Why is <code>dd if=/dev/vdX bs=512 count=1</code> not enough for a GPT disk?</summary>

It copies only the first sector. GPT keeps its partition entries after that sector and a second copy at the end of the disk.
</details>

<details>
<summary>4. How do you check a backup file before you need it?</summary>

Run `sgdisk --print` on the backup file and compare the partition count and sizes with `lsblk -f`. Also check that the file is not empty with `ls -lh`.
</details>

<details>
<summary>5. What must you do right before <code>sgdisk --zap-all</code>?</summary>

Run `lsblk -f` again and confirm the device name is the disposable disk, not the system disk.
</details>

<details>
<summary>6. Why use <code>fsck -n</code> instead of plain <code>fsck</code> for the first check?</summary>

`-n` answers "no" to every repair, so it only reports and changes nothing. You see the state of the filesystem before deciding to repair anything.
</details>

## Clean up

Each mission runs a virtual machine on your computer. When you are done with this module, remove any mission that is still running.

First, see what is still running:

```sh
astrona list
```

If the mission is still there, remove it. The command takes its **name**, not its folder path:

```sh
astrona destroy ats-002-lab-083
```

Then run `astrona list` again to check that everything is gone.
