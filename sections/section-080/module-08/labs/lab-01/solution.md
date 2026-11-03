# Solution Walkthrough

This walkthrough finds the spare disks, adds the blank one to the degraded mirror, waits for the rebuild, saves the array in `mdadm.conf`, and proves the data survived.

The commands use shell variables, so you never have to guess which device letter a disk got. The paths `/dev/disk/by-id/virtio-lab089-raid-a`, `-b` and `-c` always point at the right disks.

---

## Step 1: Find the disks and confirm the problem

```bash
DISK_A=$(readlink -f /dev/disk/by-id/virtio-lab089-raid-a)
DISK_B=$(readlink -f /dev/disk/by-id/virtio-lab089-raid-b)
DISK_C=$(readlink -f /dev/disk/by-id/virtio-lab089-raid-c)
echo "$DISK_A $DISK_B $DISK_C"
cat /proc/mdstat
sudo mdadm --detail /dev/md/cargo
```

`/proc/mdstat` shows a mirror with one member, `[U_]` or `[_U]`. `mdadm --detail` shows a degraded state and only one active device.

---

## Step 2: Add the spare disk

```bash
sudo mdadm /dev/md/cargo --add "$DISK_C"
cat /proc/mdstat
```

The array starts copying disk `a` onto disk `c`. `/proc/mdstat` shows a `recovery` line with a percentage.

---

## Step 3: Wait for the rebuild

```bash
sudo mdadm --wait /dev/md/cargo
sudo mdadm --detail /dev/md/cargo
```

When it ends, `State` is `clean`, and `Active Devices` and `Working Devices` are both 2.

---

## Step 4: Save the array

```bash
sudo mdadm --detail --scan
```

Add the `ARRAY` line it prints to the end of `/etc/mdadm/mdadm.conf`. A simple way that does not retype the UUID is:

```bash
sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf
sudo update-initramfs -u
```

Check it with `grep ARRAY /etc/mdadm/mdadm.conf`.

---

## Step 5: Mount and check the files

```bash
sudo mount /dev/md/cargo /mnt
cat /mnt/marker.txt
cat /mnt/logs/flight.log
sudo umount /mnt
```

Both files show their original text.

---

## Submit

```bash
astrona submit -c sections/section-080/module-08/labs/lab-01
```
