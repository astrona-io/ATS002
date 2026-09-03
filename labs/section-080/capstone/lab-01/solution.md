# Solution Walkthrough

Two independent recovery mechanics, back to back — exactly the kind of night a real on-call rotation eventually has. Both are the genuine repair techniques from earlier in this section, just aimed at safe stand-ins so this VM stays reachable over SSH throughout.

---

## Part 1: Restore the Secondary Disk's Partition Table

### Step 1: Identify the Secondary Disk

```bash
lsblk -f
```

```text
NAME    FSTYPE   LABEL   UUID                                 MOUNTPOINT
vda
└─vda1  ext4              1a2b3c4d-...                         /
vdc
```

`vdc` here shows no partitions at all — that's the disaster already having happened. Confirm this is the intended secondary disk by its size and by confirming it is **not** the disk mounted as `/`. Your actual device letter may differ — substitute your own from here on.

---

### Step 2: Verify the Existing Backup Is Sane

Unlike Module 3's lab, this backup already exists — check it before trusting it:

```bash
sudo sgdisk --print /root/vdc-ptable-backup.bin
```

Confirm the output shows 2 partitions with plausible sizes.

```bash
ls -lh /root/vdc-ptable-backup.bin
```

---

### Step 3: Restore From the Backup

```bash
sudo sgdisk --load-backup=/root/vdc-ptable-backup.bin /dev/vdc
```

---

### Step 4: Confirm Partitions Reappear — Then Separately Verify the Filesystems

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

## Part 2: Reinstall GRUB on the Primary Disk

### Step 5: Confirm the Symptom

```bash
ls -l /boot/grub/grub.cfg
```

```text
ls: cannot access '/boot/grub/grub.cfg': No such file or directory
```

Your SSH session staying alive right now only proves the **current** boot, which already happened before this file went missing, is unaffected.

---

### Step 6: Determine the Firmware/Boot Mode

```bash
[ -d /sys/firmware/efi ] && echo "UEFI" || echo "BIOS/legacy"
```

---

### Step 7: Identify the Primary Disk

```bash
lsblk -f
findmnt -no SOURCE /
```

Strip the partition number from the root source device (e.g. `/dev/vda1` → `/dev/vda`) to get the whole-disk device `grub-install` needs. Confirm it with `lsblk` before running anything that writes to a disk.

---

### Step 8: Reinstall GRUB's Boot-Sector/EFI Code

BIOS/legacy:

```bash
sudo grub-install /dev/vda
```

UEFI:

```bash
sudo grub-install --target=x86_64-efi --efi-directory=/boot/efi
```

---

### Step 9: Regenerate a Fresh grub.cfg

```bash
sudo update-grub
```

```bash
ls -l /boot/grub/grub.cfg
grep -c menuentry /boot/grub/grub.cfg
```

Confirm the file exists, carries a fresh timestamp, and its `menuentry` count is non-zero.

---

### Step 10: Confirm the Repair Is Durable

```bash
sudo grub-install --recheck /dev/vda        # or the --target=x86_64-efi form on UEFI
```

`--recheck` reports success without needing an actual reboot to find out.

---

## Verification

```bash
lsblk -f
sudo fsck -n /dev/vdc1 && sudo fsck -n /dev/vdc2

ls -l /boot/grub/grub.cfg
grep -c menuentry /boot/grub/grub.cfg
sudo grub-install --recheck /dev/vda
```

Once both halves verify cleanly, run the local validation suite to pass the lab.

---

## Why Both, Together

Neither half of tonight's incident depends on the other — that's deliberate. A real on-call shift rarely gets the luxury of exactly one thing being wrong at a time, and the two skills this capstone combines (partition-table backup/restore discipline, and knowing the difference between reinstalling GRUB's own code versus regenerating its menu) are independent enough that mixing them up costs you nothing on one and everything on the other. Treat them as two separate incidents that happen to share a ticket, verify each on its own terms, and don't let progress on one convince you the other is also fine.
