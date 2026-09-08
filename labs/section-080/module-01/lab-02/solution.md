# Solution Walkthrough

## 1–4. Assemble the chroot (same mechanic as lab-01)

```bash
lsblk -f
# vdb ... vdb1 ext4 DATA002ROOT ...   vdb2 xfs DATA002VOL ...   (letter may vary)

sudo mkdir -p /mnt/repair
sudo mount /dev/disk/by-id/virtio-lab085-data002-part1 /mnt/repair   # the root partition

for d in usr bin sbin lib; do sudo mount --bind /$d /mnt/repair/$d; done
[ -e /lib64 ] && sudo mount --bind /lib64 /mnt/repair/lib64
for d in dev proc sys; do sudo mount --bind /$d /mnt/repair/$d; done

sudo chroot /mnt/repair /bin/bash
cat /etc/hostname       # data-002 -> you are inside
```

## 5. Read the failure, then cross-check every field

```bash
mount -a
```

```text
mount: /data: wrong fs type, bad option, bad superblock on /dev/vdb2,
       missing codepage or helper program, or other error.
```

`wrong fs type` — not a missing device, not a bad UUID. Check what the
partition actually is:

```bash
cat /etc/fstab
# UUID=<...>  /data  ext4  defaults  0  2      <- says ext4

blkid | grep DATA002VOL
# /dev/vdb2: LABEL="DATA002VOL" UUID="<...>" TYPE="xfs"     <- it's xfs
```

The UUID matches; the **type field is wrong** — `ext4` where the partition
is `xfs`. `mount` tried the ext4 driver on an xfs superblock and failed.

Fix field 3:

```bash
sed -i 's#\(\S\+\s\+/data\s\+\)ext4#\1xfs#' /etc/fstab
# or just edit the line: change  ext4  ->  xfs
```

## 6. Prove it

```bash
mount -a
echo $?            # 0
df -hT /data       # xfs, mounted
```

`mount -a` with exit `0` is the same check a real boot performs. (The xfs
mount helper `/sbin/mount.xfs` is available inside the chroot because you
bind-mounted `/sbin` and `/usr`.)

## 7. Exit and unmount in reverse order

```bash
exit
sudo umount /mnt/repair/data 2>/dev/null
sudo umount /mnt/repair/{dev,proc,sys}
sudo umount /mnt/repair/lib64 2>/dev/null
sudo umount /mnt/repair/{lib,sbin,bin,usr}
sudo umount /mnt/repair
# or: sudo umount -R /mnt/repair
```

The lesson: `blkid` is the source of truth for **every** field of an fstab
line — device, and type. A syntactically valid entry is not a correct one.
