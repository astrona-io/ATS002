# Partition Table Backup & Recovery

The partition table is one of the smallest, most consequential structures on any disk — a few kilobytes sitting at the very start, describing where every partition begins, ends, and what type it claims to be. Lose it, or wipe it by mistake, and every filesystem on that disk becomes instantly unreachable, even though the actual file data sitting further into the disk hasn't been touched at all. The kernel simply has no idea where anything starts and ends anymore.

Reconstructing partition boundaries from memory after the fact is slow, error-prone, and sometimes impossible to get byte-exact. The professional fix is boring, cheap, and entirely preventive: back the table up *before* you ever run anything risky against a disk, so a mistake becomes a two-minute restore instead of a data-recovery emergency.

Unlike the two chroot-repair labs before this one, nothing here needs any kind of adaptation. Everything in this module operates on an ordinary secondary disk, your lab VM stays fully reachable over SSH throughout, and every command is exactly what you'd run against a real production disk.

---

## Two Different Filing Systems, Not One

It helps to separate two things that feel like one thing but genuinely are not: the **partition table** and the **filesystem** inside each partition.

Picture a warehouse with a set of numbered loading bays painted on the floor — bay 1 runs from marker 10 to marker 40, bay 2 from marker 41 to marker 90, and so on. That floor plan is the partition table: it says nothing about what's stored in each bay, only where each bay's boundaries are. Separately, each bay has its own internal shelving system, organizing whatever inventory actually lives inside it — that's the filesystem.

If someone paints over the floor markings, the inventory inside each bay is completely untouched — but forklifts can no longer find bay boundaries, so nothing is reachable until the markings are repainted. Painting the markings back (restoring the partition table) does nothing to verify the shelving inside each bay is still in good order — that's a separate check, on a separate layer, and conflating the two is the single most common mistake in this whole topic.

---

## Step 1: Positively Identify the Target Disk

```bash
lsblk -f
```

```text
NAME   FSTYPE   LABEL   UUID                                 MOUNTPOINT
vda
└─vda1 ext4              1a2b3c4d-...                         /
vdc
├─vdc1 ext4     VDC1     9f8e7d6c-...
└─vdc2 ext4     VDC2     aabbccdd-...
```

Confirm the intended secondary disk by size and existing layout, and — just as importantly — confirm it is *not* the disk mounted as `/` or holding anything else critical. This confirmation is not optional busywork. It is the single most important step in this entire module, and it gets repeated, not just checked once, immediately before the destructive step later on.

---

## Step 2: Back Up the GPT Partition Table

```bash
sudo sgdisk --backup=/root/vdc-ptable-backup.bin /dev/vdc
```

`man sgdisk`'s `--backup` option writes a binary snapshot of the GPT header and the full partition entry array — every partition's exact start/end sector, type GUID, and unique GUID — to the given file. This is a structural backup only. No file data from inside the partitions is included, by design; its only job is letting the exact partition layout be reconstructed later.

For a legacy MBR disk, the equivalent commands would be:

```bash
# MBR equivalent (contrast only — the disk in this lab is GPT):
sudo sfdisk -d /dev/vdX > /root/vdX-ptable-backup.txt
# or, an even lower-level raw first-sector capture:
sudo dd if=/dev/vdX of=/root/vdX-mbr-backup.img bs=512 count=1
```

`sfdisk -d` produces a plain-text, human-editable description that works for both MBR and GPT disks, though `sgdisk` remains the more GPT-native tool. The raw `dd` form captures only the literal first 512-byte sector — enough for a pure legacy MBR table, but note it does *not* capture an extended GPT structure, which lives beyond that first sector.

---

## Step 3: Verify the Backup Is Actually Sane

```bash
sudo sgdisk --print /root/vdc-ptable-backup.bin
```

`sgdisk` treats a backup file as if it were a device for read purposes — `--print` parses and displays its contents exactly as it would for the live disk. Confirm the output shows the expected number of partitions with plausible sizes matching Step 1's `lsblk -f`. A quick file-size sanity check is worth a glance too:

```bash
ls -lh /root/vdc-ptable-backup.bin
```

An empty, truncated, or garbled backup shows up immediately here — far better to catch that now than in the middle of an actual emergency restore.

---

## Step 4: Simulate the Disaster — Deliberately, on a Disposable Disk Only

> **This step is genuinely destructive.** Run it only against a disk you have just confirmed the identity of, and never against a disk you cannot afford to lose. Re-check the device identity immediately before this command, every single time — do not rely on having checked it earlier in the session.

```bash
lsblk -f    # re-confirm the target one more time, immediately before proceeding

sudo sgdisk --zap-all /dev/vdc
```

`--zap-all` destroys both the GPT structures and any protective MBR on the target device. This is being triggered deliberately here to create a real disaster to restore from. Outside of a lab context, there is no legitimate reason to ever run this against a disk you did not intend to fully wipe.

```bash
lsblk -f
```

`/dev/vdc` now shows no partitions at all. The floor markings are gone — but as the warehouse metaphor above stresses, the inventory inside where `vdc1`/`vdc2` used to be is still physically present on disk, simply unreachable without a table describing where it starts and ends.

---

## Step 5: Restore From the Backup

```bash
sudo sgdisk --load-backup=/root/vdc-ptable-backup.bin /dev/vdc
```

`--load-backup` writes the GPT header and partition entry array from the file back onto the target disk, recreating the exact same boundaries, types, and GUIDs that existed at backup time.

---

## Step 6: Confirm Partitions Reappear — Then Separately Verify What's Inside Them

```bash
lsblk -f
```

Partitions should reappear with the same layout as the original backup. This confirms the **partition-table layer** is restored — but stopping here leaves the job half-finished. Check the **filesystem layer** separately:

```bash
sudo fsck -n /dev/vdc1
sudo fsck -n /dev/vdc2
```

`man fsck`'s `-n` flag runs a check without making any repairs — a safe, read-only first look reporting whether each filesystem's internal structures are still consistent.

```bash
sudo mount /dev/vdc1 /mnt
ls /mnt
sudo umount /mnt
```

A successful mount and a directory listing showing the expected original files is the most concrete proof available: data is genuinely readable again, not just structurally plausible on paper. `sgdisk --load-backup` restoring the boundaries and the filesystem inside those boundaries actually being healthy are two separate facts, and only checking both proves the disk is truly usable again.

---

## Self-Check and Verification

1. **What's actually backed up:** After running `sgdisk --backup`, is any of the file data inside the partitions included in the backup file? *(Answer: No — the backup captures only the GPT header and partition entry array (boundaries, types, GUIDs). File data is untouched by this operation entirely, in both directions.)*
2. **The verification habit:** Why run `sgdisk --print` against the backup file itself, before you ever actually need it? *(Answer: To catch a truncated, empty, or corrupt backup immediately — far better discovered now, with time to fix it, than during a real emergency restore when it's too late to take a fresh one.)*
3. **The two-layer trap:** After `sgdisk --load-backup` completes and `lsblk` shows partitions reappearing correctly, is the disk confirmed healthy? *(Answer: No — the partition-table layer is restored, but the filesystems inside need a separate check with `fsck -n` and/or a mount-and-inspect pass; restoring boundaries says nothing about what's inside them.)*
