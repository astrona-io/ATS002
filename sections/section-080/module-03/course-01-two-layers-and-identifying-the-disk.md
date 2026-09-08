# Part 1 — Two layers, not one, and identifying the target disk

> Prerequisite: [module landing page](./course.md). Next: [Part 2 — Back up the partition table, and verify the backup](./course-02-backup-and-verify.md).

The partition table and the filesystems inside it are separate layers, and conflating them is the most common mistake in this topic. This part settles that distinction and the single most important safety step: positively identifying which disk you are about to operate on.

## Partition table vs. filesystem

The **partition table** is a few kilobytes at the very start of a disk describing where each partition begins, ends, and what type it claims to be. Lose it and every filesystem on that disk becomes instantly unreachable — even though the file data further into the disk is untouched. The kernel simply no longer knows where anything starts.

The **filesystem** is the structure *inside* each partition — inodes, directories, the free-space map.

As an analogy (flagged): a warehouse floor has numbered loading bays painted on it — bay 1 from marker 10 to 40, bay 2 from 41 to 90. That floor plan is the partition table: only boundaries, nothing about contents. Each bay's internal shelving is its filesystem. Paint over the markings and the inventory is untouched, but forklifts cannot find bay boundaries — nothing is reachable until the markings are repainted. Repainting the markings (restoring the table) says **nothing** about whether the shelving inside is still in order. Where it breaks down: real floor paint degrades gradually; a partition table is either intact or gone.

**The trap:** restoring the table and calling the disk healthy. That is half the job — the filesystem layer needs its own separate check (Part 3).

## Positively identify the target disk

```bash
# shell: repair host, unprivileged for the read
lsblk -f
```

```text
NAME   FSTYPE  LABEL   UUID          MOUNTPOINT
vda
└─vda1 ext4            1a2b3c4d-...  /
vdc
├─vdc1 ext4    VDC1    9f8e7d6c-...
└─vdc2 ext4    VDC2    aabbccdd-...
```

Confirm the intended secondary disk by size and existing layout — **and confirm it is not the disk mounted as `/`** or holding anything else critical. This is not busywork: it is the single most important step in the module, and Part 3 repeats it immediately before the destructive command. `sudo blkid` gives the same facts from another angle.

> [!WARNING]
> - **Restoring the partition table and stopping** → the filesystems inside are a separate layer needing `fsck -n` and a mount test (Part 3).
> - **Guessing the target from a bare device name** → `lsblk -f` by label/size/layout; a wrong guess here later wipes the wrong disk.
> - **Assuming "secondary disk" means safe** → verify it is not `/`, not swap in use, not holding live data.

> *The partition table (boundaries) and the filesystems inside it are separate layers — restoring one proves nothing about the other — and identifying the exact target disk with `lsblk -f` is the module's most important step, repeated before anything destructive.*

## Reference

- `man lsblk` — `-f`, `-o`, `-p`; the combined device/fs/UUID view.
- `man 8 sgdisk` / `man 8 gdisk` — GPT structure: the header, the partition entry array, the backup header at the end of the disk.
- `man 8 blkid` — the cross-check for filesystem type and UUID.
