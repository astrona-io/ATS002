# Question

Solve this question on: `terminal`

This machine has a spare disk with the serial `lab086-data001`. It holds one partition with an ext4 filesystem (label `CARGO`) with a file `marker.txt` and a file `logs/flight.log` that must not be lost. The filesystem will not mount, because its primary superblock was overwritten with zeros.

1. Find the spare disk and its partition. It is **not** the disk mounted as `/`. Do not assume a device letter such as `/dev/vdb`.
2. Confirm the problem: try to mount the partition, and try to read its superblock with `dumpe2fs -h`. Both fail.
3. Find a backup superblock. The filesystem uses 4096-byte blocks.
4. Repair the filesystem with `e2fsck`, telling it to use that backup superblock, and let it fix what it finds.
5. Write the number of the backup superblock you used into `/root/backup-superblock.txt`, as the only content of the file.
6. Check the filesystem again with a forced read-only check, mount it, and confirm both files are still there. Unmount it when you are done.

The grader checks that:

- the partition has a readable ext4 superblock again
- `fsck.ext4 -n -f` finds no errors, and the partition is not mounted
- the partition mounts and `marker.txt` and `logs/flight.log` still have their original content
- `/root/backup-superblock.txt` names one of the filesystem's backup superblocks
<!-- curriculum-links -->

## Related lessons and assessment

Read [module-05](../../course.md).

The grader checks:

- Confirms the partition has a readable ext4 superblock again.
- Confirms fsck.ext4 -n -f finds no errors and the partition is not mounted.
- Confirms the filesystem mounts and both original files have their original content.
- Confirms /root/backup-superblock.txt names one of the filesystem's backup superblocks.

Use the inspection commands in the solution to check your work. Submit when you have finished; submission ends this environment.
