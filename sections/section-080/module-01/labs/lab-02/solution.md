# Solution Walkthrough

The broken `data-002` system lives on a second, disposable disk (serial `lab085-data002`). The chroot steps are the same as for any fstab repair. The new skill is reading the error and checking every field of the line, not just the device.

---

## Steps 1 to 4: Build the chroot

Find the disk, mount its root partition, bind in the tools and the kernel folders, and step inside:

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

The `/dev/disk/by-id/virtio-lab085-data002-part1` path finds the root partition by the disk's serial number, so it works whatever device letter the disk got. The two `for` loops run the same `mount --bind` command once for each folder in the list.

---

## Step 5: Read the failure, then check every field

```bash
mount -a
```

```text
mount: /data: wrong fs type, bad option, bad superblock on /dev/vdb2,
       missing codepage or helper program, or other error.
```

`wrong fs type` is not a missing device and not a bad UUID. Check what the partition really is:

```bash
cat /etc/fstab
# UUID=<...>  /data  ext4  defaults  0  2      <- says ext4

blkid | grep DATA002VOL
# /dev/vdb2: LABEL="DATA002VOL" UUID="<...>" TYPE="xfs"     <- it's xfs
```

The UUID matches. The **type field is wrong**: the line says `ext4`, but the partition is `xfs`. `mount` tried the ext4 driver on an xfs filesystem, and the ext4 driver could not read it.

Fix field 3:

```bash
sed -i 's#\(\S\+\s\+/data\s\+\)ext4#\1xfs#' /etc/fstab
# or just edit the line: change  ext4  ->  xfs
```

This `sed` command finds the first field, the spaces and `/data` that come before `ext4`, keeps them, and replaces only `ext4` with `xfs`. Editing the line by hand in `nano` or `vi` gives the same result. Leave the `UUID=` part alone; it was never wrong.

---

## Step 6: Prove it

```bash
mount -a
echo $?            # 0
df -hT /data       # xfs, mounted
```

`mount -a` with exit code `0` is the same check a real boot performs. The xfs mount helper `/sbin/mount.xfs` works inside the chroot because you bind-mounted `/sbin` and `/usr`.

---

## Step 7: Exit and unmount in reverse order

```bash
exit
sudo umount /mnt/repair/data 2>/dev/null
sudo umount /mnt/repair/{dev,proc,sys}
sudo umount /mnt/repair/lib64 2>/dev/null
sudo umount /mnt/repair/{lib,sbin,bin,usr}
sudo umount /mnt/repair
# or: sudo umount -R /mnt/repair
```

The lesson: `blkid` is the source of truth for **every** field of an fstab line that names something real, the device and the type. A line can be perfectly written and still be wrong.

When you are done, send the lab for grading from your own computer:

```bash
astrona submit -c sections/section-080/module-01/labs/lab-02
```
