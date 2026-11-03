# Solution Walkthrough

This walkthrough runs the full backup, wipe and restore cycle on the secondary disk, then checks both layers: the partition table and the filesystems inside it.

The commands below use `/dev/vdc` because the disk's serial is `lab083-vdc`. On these training ships a single extra disk usually appears as `/dev/vdb` instead. Use the name your own `lsblk -f` shows in every command, including the partition names (`vdb1`, `vdb2`). The path `/dev/disk/by-id/virtio-lab083-vdc` always points at the right disk.

---

## Step 1: Identify the secondary disk

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

This output is a shortened example. On Ubuntu 24.04, `lsblk -f` shows a few more columns and the main disk has more partitions.

Confirm that this is the intended secondary disk: about 2 GB, two partitions labelled `VDC1` and `VDC2`, and **not** the disk mounted as `/`.

---

## Step 2: Back up the GPT partition table

```bash
sudo sgdisk --backup=/root/vdc-ptable-backup.bin /dev/vdc
```

This writes the GPT headers and the full list of partition entries (exact start and end sectors, type IDs, unique IDs) to the file. No file data from inside the partitions is included, on purpose.

---

## Step 3: Check that the backup is good

```bash
sudo sgdisk --print /root/vdc-ptable-backup.bin
```

Confirm that the output shows 2 partitions with sizes that match Step 1.

```bash
ls -lh /root/vdc-ptable-backup.bin
```

A file size that is not zero is a quick extra check.

---

## Step 4: Practice disaster

This really destroys the table. Confirm the device name again right before you run it.

```bash
lsblk -f    # re-confirm /dev/vdc one more time, immediately before proceeding

sudo sgdisk --zap-all /dev/vdc
```

```bash
lsblk -f
```

The secondary disk should now show no partitions at all.

---

## Step 5: Restore from the backup

```bash
sudo sgdisk --load-backup=/root/vdc-ptable-backup.bin /dev/vdc
```

---

## Step 6: Confirm the partitions, then check the filesystems separately

```bash
lsblk -f
```

Both partitions should be back with their original layout. That confirms the partition table layer only. Check the filesystem layer on its own:

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

Both marker files should read exactly as before the disaster. Together with a clean `fsck -n`, that proves the disk is usable again. The table restore alone only proved the boundaries were back.

---

## Verification

```bash
lsblk -f                                    # both partitions present
sudo fsck -n /dev/vdc1 && sudo fsck -n /dev/vdc2   # both clean
```

Leave both partitions unmounted. When both checks pass, send the lab for grading from your own computer:

```bash
astrona submit -c sections/section-080/module-03/labs/lab-01
```
