# Solution Walkthrough

---

## Step 1: Identify the Secondary Disk

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

Confirm this is the intended secondary disk by its size and existing two-partition layout, and confirm it is **not** the disk mounted as `/`. Your actual device letter may differ — substitute your own from here on.

---

## Step 2: Back Up the GPT Partition Table

```bash
sudo sgdisk --backup=/root/vdc-ptable-backup.bin /dev/vdc
```

This writes a binary snapshot of the GPT header and full partition entry array — exact start/end sectors, type GUIDs, unique GUIDs — to the given file. No file data from inside the partitions is included, by design.

---

## Step 3: Verify the Backup Is Sane

```bash
sudo sgdisk --print /root/vdc-ptable-backup.bin
```

Confirm the output shows 2 partitions with sizes matching Step 1's `lsblk -f`.

```bash
ls -lh /root/vdc-ptable-backup.bin
```

A non-zero, plausible file size is a quick extra sanity check.

---

## Step 4: Simulate the Disaster

> Genuinely destructive. Re-confirm the device identity immediately before this command, every time.

```bash
lsblk -f    # re-confirm /dev/vdc one more time, immediately before proceeding

sudo sgdisk --zap-all /dev/vdc
```

```bash
lsblk -f
```

`/dev/vdc` should now show no partitions at all.

---

## Step 5: Restore From the Backup

```bash
sudo sgdisk --load-backup=/root/vdc-ptable-backup.bin /dev/vdc
```

---

## Step 6: Confirm Partitions Reappear — Then Separately Verify the Filesystems

```bash
lsblk -f
```

Both partitions should reappear with the original layout. This confirms the partition-table layer only — check the filesystem layer separately:

```bash
sudo fsck -n /dev/vdc1
sudo fsck -n /dev/vdc2
```

```bash
sudo mkdir -p /mnt/check1 /mnt/check2
sudo mount /dev/vdc1 /mnt/check1
cat /mnt/check1/marker.txt
sudo umount /mnt/check1

sudo mount /dev/vdc2 /mnt/check2
cat /mnt/check2/marker.txt
sudo umount /mnt/check2
```

Both marker files should read back exactly as they were before the disaster. That, combined with a clean `fsck -n`, is what actually proves the disk is usable again — the partition-table restore alone only proved the boundaries were back.

---

## Verification

```bash
lsblk -f                                    # both partitions present
sudo fsck -n /dev/vdc1 && sudo fsck -n /dev/vdc2   # both clean
```

Once verified, run the local validation suite to pass the lab.
