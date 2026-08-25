# Question

Solve this question on: `terminal`

This VM has a secondary, GPT-partitioned disk attached — already carrying two ext4 partitions, each with a `marker.txt` file inside — that's about to have risky partitioning work done on it. Before touching anything, back it up so a mistake can be undone without reconstructing partitions from memory.

1.  Identify the secondary disk with `lsblk -f` (it is **not** the disk mounted as `/`, and it already has two partitions on it — do not assume a specific `/dev/vdX` letter).
2.  Back up its GPT partition table with `sgdisk --backup` to exactly this path: `/root/vdc-ptable-backup.bin`.
3.  Verify the backup is sane with `sgdisk --print` against the backup file itself, before you'd ever actually need it.
4.  **Strictly as a disposable lab exercise** — re-confirm the device identity one more time immediately beforehand, then simulate a disaster with `sgdisk --zap-all` against the secondary disk.
5.  Restore the partition table from your backup with `sgdisk --load-backup`.
6.  Confirm partitions reappear with `lsblk -f`, then — as a **separate** check — confirm the filesystems inside them are actually intact: run `fsck -n` on each partition, and mount each one to confirm its original `marker.txt` file is still there with its original content.
