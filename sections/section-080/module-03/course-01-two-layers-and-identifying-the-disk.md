# Two Layers And The Target Disk

Astronaut, before you touch a disk's deck plan, you need two ideas fixed in your head. The partition table and the filesystems inside it are two separate layers, and mixing them up is the most common mistake in this topic. And you must know, without guessing, which disk you are about to change.

## Partition table versus filesystem

A disk holds two layers, one inside the other. Each one can be healthy or broken on its own.

### The partition table

The **partition table** is a small area at the start of the disk. It lists where each partition begins and ends, and what type it claims to be. On a GPT disk (GUID Partition Table, the modern format) there is also a second copy of the table at the very end of the disk.

In the ship picture, the partition table is the deck plan: it marks where each cargo deck starts and ends, and says nothing about the cargo. Lose it and the kernel no longer knows where any partition starts. Every filesystem on the disk becomes unreachable at once, even though the data further into the disk is untouched.

### The filesystem

The **filesystem** is the structure inside each partition: the folders, the files, the records of which space is free. It is the cargo and its shelving inside one deck.

Redrawing the deck plan, that is restoring the partition table, says **nothing** about whether the cargo inside each deck is still in order. A partition can come back with exactly the right boundaries and still hold a damaged filesystem.

**The trap:** restoring the table and calling the disk healthy. That is only half the job. The filesystem layer needs its own separate check with `fsck -n` and a test mount.

## Be sure which disk you are about to touch

Every command in this module writes to a whole disk. So the most important step comes first: identify the target disk without guessing.

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

This output is a shortened example. On Ubuntu 24.04, `lsblk -f` shows a few more columns, the main disk has more partitions, and a single extra disk usually appears as `vdb` rather than `vdc`.

Confirm the intended secondary disk by its size, its labels and its partition layout. Then confirm that it is **not** the disk mounted as `/`, not holding swap in use, and not holding anything else you need. `sudo blkid` gives the same facts from another angle.

This is not busywork. It is the single most important step in the whole procedure, and you repeat it right before any command that destroys something.

## Common pitfalls

> [!WARNING]
> - **Restoring the partition table and stopping there.** The filesystems inside are a separate layer that needs `fsck -n` and a test mount.
> - **Guessing the target from a bare device name.** Use `lsblk -f` to check label, size and layout. A wrong guess here later wipes the wrong disk.
> - **Assuming "secondary disk" means safe.** Check that it is not `/`, not swap in use and not holding live data.
