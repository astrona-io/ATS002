# Solution Walkthrough

This lab's "broken system" lives on a second, disposable disk (`extraDisks`, serial `lab081-data001`) so the VM you're actually SSHed into never has to become unreachable for the lab to be real. Every command below is the genuine chroot-repair mechanic — just aimed at that stand-in disk.

---

## Step 1: Identify the Partitions

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

The labels make it obvious here: `DATA001ROOT` is the stand-in "data-001" root filesystem, `DATA001VOL` is the data volume its (broken) fstab entry is supposed to mount. Note the actual device letters — they can vary run to run, so don't hardcode `/dev/vdb` in anything you type from here on; substitute your own.

---

## Step 2: Mount the Root Partition

```bash
sudo mkdir -p /mnt/repair
sudo mount /dev/vdb1 /mnt/repair
```

---

## Step 3: Bind-Mount Tools In (Read-Only)

The stand-in disk only carries `/etc`, not a full userland — there's no `bash`, `mount`, or `blkid` on it to chroot into usefully. Bind-mount this VM's own real binaries and libraries in:

```bash
sudo mount --bind /usr /mnt/repair/usr
sudo mount --bind /bin /mnt/repair/bin
sudo mount --bind /sbin /mnt/repair/sbin
sudo mount --bind /lib /mnt/repair/lib
[ -e /lib64 ] && sudo mount --bind /lib64 /mnt/repair/lib64
```

`mount --bind` re-attaches an already-mounted directory tree at a second location — nothing is copied. `/mnt/repair/etc`, the part that actually matters here, stays exactly what's on the stand-in disk.

---

## Step 4: Bind-Mount /dev, /proc, /sys

```bash
sudo mount --bind /dev /mnt/repair/dev
sudo mount --bind /proc /mnt/repair/proc
sudo mount --bind /sys /mnt/repair/sys
```

Skip this and tools inside the chroot fail in ways that look completely unrelated — `blkid` returning nothing despite real partitions existing is the classic symptom.

---

## Step 5: chroot In

```bash
sudo chroot /mnt/repair /bin/bash
```

Confirm you're really inside the stand-in system:

```bash
cat /etc/hostname
# data-001
```

---

## Step 6: Find and Fix the Typo

```bash
cat /etc/fstab
```

```text
# /etc/fstab: static file system information for data-001
UUID=aabbccdd-5555-6666-7777-8888dead  /data  ext4  defaults  0  2
```

Cross-check against reality:

```bash
blkid
```

Suppose `blkid` shows the data partition's real UUID is `aabbccdd-5555-6666-7777-888899990000` — the fstab line's last four characters (`dead`) are the typo. Fix it:

```bash
sed -i 's/aabbccdd-5555-6666-7777-8888dead/aabbccdd-5555-6666-7777-888899990000/' /etc/fstab
```

Confirm the mount point exists:

```bash
mkdir -p /data
```

---

## Step 7: Prove the Fix

```bash
mount -a
echo $?
```

Exit `0` and no errors means the corrected line is genuinely mountable — the same check a real boot's systemd performs.

```bash
df -h /data
```

---

## Step 8: Exit and Unmount Cleanly

```bash
exit
```

```bash
sudo umount -R /mnt/repair
```

`umount -R` recursively unmounts everything under `/mnt/repair` — the bind mounts and whatever `mount -a` mounted — in one command, achieving the same end state as unmounting each one individually in reverse order.

---

## Verification

```bash
sudo mkdir -p /mnt/check
sudo mount -o ro /dev/vdb1 /mnt/check
grep UUID= /mnt/check/etc/fstab
sudo umount /mnt/check
```

The line should now show the data partition's real UUID (matching `blkid /dev/vdb2`), not the mistyped one bootstrap seeded. Once verified, run the local validation suite to pass the lab.
