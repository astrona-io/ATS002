# Solution Walkthrough

This walkthrough finds the spare disk, rebuilds its LVM label from the metadata backup, restores the volume group, and proves the data survived.

The commands use a shell variable, so you never have to guess whether the extra disk is `/dev/vdb` or `/dev/vdc`. The path `/dev/disk/by-id/virtio-lab088-pv001` always points at the right disk.

---

## Step 1: Find the spare disk and confirm the problem

```bash
DISK=$(readlink -f /dev/disk/by-id/virtio-lab088-pv001)
echo "$DISK"
lsblk "$DISK"
sudo pvs
sudo vgs
```

Confirm that this is a small disk with no partitions, and that it is **not** the disk mounted as `/`. `pvs` and `vgs` show nothing, because the LVM label is gone.

---

## Step 2: Find the backup and read the UUID

```bash
sudo ls -l /etc/lvm/backup
sudo vgcfgrestore --list cargo_vg
sudo grep -A3 'pv0 {' /etc/lvm/backup/cargo_vg
```

The file `/etc/lvm/backup/cargo_vg` holds the latest layout. Under `pv0` the line `id = "..."` is the UUID of the physical volume. Copy it, with its dashes.

---

## Step 3: Recreate the physical volume

```bash
sudo pvcreate --uuid "<UUID>" --restorefile /etc/lvm/backup/cargo_vg "$DISK"
```

Replace `<UUID>` with the value you copied. This writes the old label again and does not touch the data. It does not create a filesystem.

---

## Step 4: Restore the group and activate it

```bash
sudo vgcfgrestore cargo_vg
sudo vgchange -ay cargo_vg
sudo lvs
```

`lvs` now shows `deck` with an `a` in the fifth attribute place.

---

## Step 5: Mount the deck and check the files

```bash
sudo mkdir -p /srv/deck
sudo mount /dev/cargo_vg/deck /srv/deck
cat /srv/deck/marker.txt
cat /srv/deck/logs/flight.log
```

Both files show their original text. Leave the deck mounted, because the grader checks the mount.

---

## Submit

```bash
astrona submit -c sections/section-080/module-07/labs/lab-01
```
