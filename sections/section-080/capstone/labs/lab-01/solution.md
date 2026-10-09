# Solution Walkthrough

Two separate recovery jobs, back to back: the kind of night every on-call shift meets sooner or later. Both are the real repair techniques, aimed at safe targets so this machine stays reachable over SSH the whole time.

---

## First job: restore the secondary disk's partition table

The secondary disk's table is already wiped, and a backup is already on file. You restore it and then check both layers: the table and the filesystems inside it.

### Step 1: Identify the secondary disk

```bash
lsblk -f
```

```text
NAME    FSTYPE   LABEL   UUID                                 MOUNTPOINT
vda
└─vda1  ext4              1a2b3c4d-...                         /
vdc
```

This output is a shortened example. On Ubuntu 24.04, `lsblk -f` shows a few more columns and the main disk has more partitions. A single extra disk also usually appears as `vdb`, not `vdc`.

The secondary disk shows no partitions at all: the disaster has already happened. Confirm that it is the intended disk by its size (about 2 GB) and that it is **not** the disk mounted as `/`. The commands below use `/dev/vdc`; use the name your own `lsblk -f` shows, including for the partitions (`vdb1`, `vdb2`). The path `/dev/disk/by-id/virtio-lab080-vdc` always points at this disk.

---

### Step 2: Check the existing backup

This backup was taken by someone else, so check it before you trust it:

```bash
sudo sgdisk --print /root/vdc-ptable-backup.bin
```

Confirm that the output shows 2 partitions with sensible sizes.

```bash
ls -lh /root/vdc-ptable-backup.bin
```

---

### Step 3: Restore from the backup

```bash
sudo sgdisk --load-backup=/root/vdc-ptable-backup.bin /dev/vdc
```

---

### Step 4: Confirm the partitions, then check the filesystems separately

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

## Second job: repair GRUB on the main disk

Only `/boot/grub/grub.cfg` is missing, but a full repair runs both tools: `grub-install` for the boot code and `update-grub` for the menu file.

### Step 5: Confirm the symptom

```bash
ls -l /boot/grub/grub.cfg
```

```text
ls: cannot access '/boot/grub/grub.cfg': No such file or directory
```

Your SSH session working right now only proves that the current boot, which finished before this file went missing, is unaffected.

---

### Step 6: Find the firmware type

```bash
[ -d /sys/firmware/efi ] && echo "UEFI" || echo "BIOS/legacy"
```

---

### Step 7: Identify the primary disk

```bash
lsblk -f
findmnt -no SOURCE /
```

Remove the partition number from the device `findmnt` prints (for example `/dev/vda1` becomes `/dev/vda`) to get the whole disk that `grub-install` needs on BIOS. Confirm it with `lsblk` before running anything that writes to a disk.

---

### Step 8: Reinstall GRUB's boot code

BIOS/legacy:

```bash
sudo grub-install /dev/vda
```

UEFI:

```bash
sudo grub-install --target=x86_64-efi --efi-directory=/boot/efi
```

The UEFI form above is for 64-bit Intel and AMD machines; on an ARM computer the target is `arm64-efi`. Either form also rewrites GRUB's core image under `/boot/grub`, which is how the grader knows you ran it.

---

### Step 9: Write a fresh grub.cfg

```bash
sudo update-grub
```

```bash
ls -l /boot/grub/grub.cfg
grep -c menuentry /boot/grub/grub.cfg
```

Confirm that the file exists, has a fresh timestamp, and that its `menuentry` count is above zero.

---

### Step 10: Check the repair

```bash
sudo grub-install --recheck /dev/vda        # or the --target=x86_64-efi form on UEFI
```

`--recheck` makes `grub-install` look at the disks again and install once more. A run that ends with `No error reported` shows the repair works, without a reboot.

---

## Verification

```bash
lsblk -f
sudo fsck -n /dev/vdc1 && sudo fsck -n /dev/vdc2

ls -l /boot/grub/grub.cfg
grep -c menuentry /boot/grub/grub.cfg
sudo grub-install --recheck /dev/vda
```

When both halves check out, send the lab for grading from your own computer:

```bash
astrona submit -c sections/section-080/capstone/labs/lab-01
```

---

## Why both, together

Neither half of tonight's incident depends on the other, and that is on purpose. A real on-call shift rarely has exactly one thing wrong at a time. Treat the two problems as two separate incidents that share one ticket. Check each one on its own terms, and do not let progress on one convince you the other is fine too.
