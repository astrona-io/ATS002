# Question

Solve this question on: `terminal`

This machine has a secondary disk with a GPT partition table (serial `lab083-vdc`). It holds two ext4 partitions, and each one has a `marker.txt` file inside. Risky partitioning work is about to be done on it, so back it up first, so that a mistake can be undone without rebuilding partitions from memory.

1. Identify the secondary disk. It is **not** the disk mounted as `/`, and it already has two partitions. Do not assume a device letter such as `/dev/vdb`.
2. Back up its GPT partition table with `sgdisk --backup` to exactly this path: `/root/vdc-ptable-backup.bin`.
3. Check that the backup is good by running `sgdisk --print` on the backup file itself.
4. As a practice disaster, confirm the device name once more, then wipe the secondary disk's partition table with `sgdisk --zap-all`.
5. Restore the partition table from your backup with `sgdisk --load-backup`.
6. Confirm the partitions are back, then check the filesystems separately: run `fsck -n` on each partition, and mount each one to confirm its `marker.txt` is still there with its original content. Unmount them again when you are done.

The grader checks that:

- `/root/vdc-ptable-backup.bin` exists and is not empty
- the secondary disk has both of its partitions again
- each partition passes `fsck -n` without errors, mounts, and still holds its original `marker.txt` with its original content
