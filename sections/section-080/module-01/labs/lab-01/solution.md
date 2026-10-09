# Solution Walkthrough

The broken `data-001` system lives on a second, disposable disk (serial `lab081-data001`), so the machine you are logged in to never has to stop responding. Every command below is the real chroot repair, aimed at that stand-in disk. Your machine plays the rescue ship; the stand-in disk is the damaged one.

---

## Step 1: Identify the partitions

```bash
lsblk -f
```

```text
NAME    FSTYPE   LABEL         UUID                                 MOUNTPOINT
vda
└─vda1  ext4                   1a2b3c4d-...                         /
vdb
├─vdb1  ext4     DATA001ROOT   9f8e7d6c-1111-2222-3333-444455556666
└─vdb2  ext4     DATA001VOL    aabbccdd-5555-6666-7777-888899990000
```

This output is a shortened example and its UUIDs are made up. On Ubuntu 24.04, `lsblk -f` shows a few more columns and more partitions on the main disk, and your UUIDs will be different.

The labels make the roles clear. `DATA001ROOT` is the stand-in `data-001` root filesystem. `DATA001VOL` is the data volume its broken fstab line should mount. The device letter can change from run to run, so do not copy `/dev/vdb` blindly; use the name your own `lsblk -f` shows. The stable path `/dev/disk/by-id/virtio-lab081-data001-part1` always points at the root partition.

---

## Step 2: Mount the root partition

```bash
sudo mkdir -p /mnt/repair
sudo mount /dev/vdb1 /mnt/repair
```

---

## Step 3: Bind-mount the tools in

The stand-in disk carries only `/etc`, not a full set of programs. There is no `bash`, `mount` or `blkid` on it. Lend it this machine's own programs and libraries:

```bash
sudo mount --bind /usr /mnt/repair/usr
sudo mount --bind /bin /mnt/repair/bin
sudo mount --bind /sbin /mnt/repair/sbin
sudo mount --bind /lib /mnt/repair/lib
[ -e /lib64 ] && sudo mount --bind /lib64 /mnt/repair/lib64
```

`mount --bind` shows a folder that is already mounted at a second place. Nothing is copied. `/mnt/repair/etc`, the part that matters, stays exactly what is on the stand-in disk.

---

## Step 4: Bind-mount `/dev`, `/proc` and `/sys`

```bash
sudo mount --bind /dev /mnt/repair/dev
sudo mount --bind /proc /mnt/repair/proc
sudo mount --bind /sys /mnt/repair/sys
```

These are the power cables from the rescue ship. Skip them and tools inside the chroot fail in ways that look unrelated. The classic sign is `blkid` printing nothing even though the partitions are there.

---

## Step 5: chroot in

```bash
sudo chroot /mnt/repair /bin/bash
```

Confirm you are really inside the stand-in system:

```bash
cat /etc/hostname
# data-001
```

---

## Step 6: Find and fix the typo

```bash
cat /etc/fstab
```

```text
# /etc/fstab: static file system information for data-001
UUID=aabbccdd-5555-6666-7777-8888dead  /data  ext4  defaults  0  2
```

Compare it with what the disks really say:

```bash
blkid
```

Suppose `blkid` shows the data partition's real UUID is `aabbccdd-5555-6666-7777-888899990000`. Then the last four characters of the fstab line (`dead`) are the typo. In the lab, the bootstrap script made the bad UUID by replacing the last four characters of the real one with `dead`, so your line will also end in `dead`, but the rest of your UUID is different. Fix it:

```bash
sed -i 's/aabbccdd-5555-6666-7777-8888dead/aabbccdd-5555-6666-7777-888899990000/' /etc/fstab
```

Put your own two UUIDs into this command, or edit the line with `nano` or `vi`. Keep `/data` and `ext4` as they are; the grader checks for them.

Make sure the mount point exists:

```bash
mkdir -p /data
```

---

## Step 7: Prove the fix

```bash
mount -a
echo $?
```

An exit code of `0` and no errors means the corrected line can really be mounted. This is the same check systemd performs during a real boot.

```bash
df -h /data
```

`df` should show the data partition mounted on `/data`.

---

## Step 8: Exit and unmount cleanly

```bash
exit
```

```bash
sudo umount -R /mnt/repair
```

`umount -R` unmounts everything under `/mnt/repair` (the bind mounts and the `/data` mount that `mount -a` made) and then `/mnt/repair` itself. It reaches the same end state as unmounting each one by hand in reverse order.

---

## Verification

Check the result from outside any chroot, the same way the grader does:

```bash
sudo mkdir -p /mnt/check
sudo mount -o ro /dev/vdb1 /mnt/check
grep UUID= /mnt/check/etc/fstab
sudo umount /mnt/check
```

The line should now show the data partition's real UUID (the one `sudo blkid /dev/vdb2` prints), not the mistyped one. When it does, send the lab for grading from your own computer:

```bash
astrona submit -c sections/section-080/module-01/labs/lab-01
```
