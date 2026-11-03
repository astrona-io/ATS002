# Solution Walkthrough

This walkthrough finds the damaged partition, repairs the filesystem from a backup superblock, and proves the data survived.

The commands use a shell variable, so you never have to guess whether the extra disk is `/dev/vdb` or `/dev/vdc`. The path `/dev/disk/by-id/virtio-lab086-data001` always points at the right disk.

---

## Step 1: Find the spare disk

```bash
DISK=$(readlink -f /dev/disk/by-id/virtio-lab086-data001)
echo "$DISK"
lsblk -f "$DISK"
```

Confirm that this is a small disk with one partition, and that it is **not** the disk mounted as `/`. The partition is `${DISK}1`. The file system type column may be empty for it, because the superblock that says what it is has been wiped.

---

## Step 2: Confirm the problem

```bash
sudo mount "${DISK}1" /mnt
sudo dumpe2fs -h "${DISK}1"
```

Both commands fail. The mount message mentions a wrong filesystem type or a bad superblock, and `dumpe2fs` reports that it cannot read a valid superblock. The exact wording differs between versions, so do not match it character by character.

---

## Step 3: Find a backup superblock

A filesystem keeps spare copies of its superblock. With 4096-byte blocks the first backup is at block 32768, and further backups sit at 98304, 163840 and 229376 on a filesystem of this size.

You can also ask `mke2fs` where it would place them. **Read this warning first:** the `-n` option makes it a dry run that changes nothing. Without `-n` the same command creates a new, empty filesystem and destroys your data.

```bash
sudo mke2fs -n -b 4096 "${DISK}1"
```

Look for the list that starts with `Superblock backups stored on blocks:`. Use the first number in that list.

---

## Step 4: Repair with the backup superblock

```bash
sudo e2fsck -b 32768 -y "${DISK}1"
```

`-b 32768` tells `e2fsck` to read the filesystem description from the backup superblock. `-y` answers yes to every repair question. Expect a number of messages about wrong free block and inode counts: those fields are only kept up to date in the primary copy, so `e2fsck` corrects them. The run ends by writing a fresh primary superblock.

---

## Step 5: Record the backup you used

```bash
echo 32768 | sudo tee /root/backup-superblock.txt
```

Use the number you actually used if it was a different one from the list.

---

## Step 6: Check it again and look at the files

```bash
sudo fsck.ext4 -n -f "${DISK}1"
sudo mount "${DISK}1" /mnt
cat /mnt/marker.txt
cat /mnt/logs/flight.log
sudo umount /mnt
```

The forced read-only check should report that the filesystem is clean. The two files should show their original text. Unmount before you submit, because the grader checks that the partition is not mounted.

---

## Submit

```bash
astrona submit -c sections/section-080/module-05/labs/lab-01
```
