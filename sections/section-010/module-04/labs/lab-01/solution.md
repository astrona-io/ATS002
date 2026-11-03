# Solution Walkthrough

This walkthrough finds the backup disk, writes a udev rule that matches it by serial number, and applies the rule without a reboot. You can run `astrona submit` after any step: each failing check names the one thing still missing.

---

## Step 1: Find the disk's current (unstable) device node

```bash
lsblk
```

Look for the extra 1 GB disk that already has one partition holding the backup data, and note its current letter. The commands below use `/dev/vdb` and `/dev/vdb1` as the example. On this image `vdb` is often the small cloud-init disk, so the backup disk may well be `/dev/vdc` on your machine. Use the letter that `lsblk` shows you.

---

## Step 2: Find a stable identifying attribute

```bash
udevadm info --query=all --name=/dev/vdb
```

If the serial does not show there, walk the device's whole parent chain:

```bash
udevadm info --attribute-walk --name=/dev/vdb
```

Look for the serial `lab014-backup-drive`. On this virtio disk it shows as `ATTR{serial}=="lab014-backup-drive"` on the disk itself. The serial stays with the physical disk, whatever `/dev/vdX` letter the kernel gives it. `ATTRS{serial}` in a rule matches it on the disk and also on the disk's partitions, because `ATTRS{}` searches the parent levels too.

---

## Step 3: Write the custom rule

Save this as `/etc/udev/rules.d/99-backup-drive.rules`:

```
SUBSYSTEM=="block", ATTRS{serial}=="lab014-backup-drive", KERNEL=="vd[a-z]", SYMLINK+="backup-drive"
SUBSYSTEM=="block", ATTRS{serial}=="lab014-backup-drive", KERNEL=="vd[a-z]1", SYMLINK+="backup-drive1"
```

The first line matches the whole disk and creates `/dev/backup-drive`. The second line matches only its first partition and creates `/dev/backup-drive1`, the node the backup script needs to mount. Both lines match on `ATTRS{serial}`, the stable attribute from Step 2. The `KERNEL==` patterns only tell the disk (`vdc`) apart from its partition (`vdc1`); they work for any letter.

---

## Step 4: Apply the new rule without rebooting

```bash
sudo udevadm control --reload-rules
sudo udevadm trigger --subsystem-match=block
```

`--reload-rules` tells the running `systemd-udevd` to read the rule files from disk again. `trigger` is still needed afterwards: it replays the device events, so `systemd-udevd` runs the new rule against the disk that is already connected.

---

## Step 5: Check that the links appeared

```bash
ls -l /dev/backup-drive /dev/backup-drive1
```

Both should be symbolic links: one to the disk's current letter, one to its first partition.

---

## Verification

```bash
udevadm info --query=all --name=/dev/backup-drive | grep -E 'DEVLINKS|ID_SERIAL'

ls -l /dev/backup-drive /dev/backup-drive1

# re-trigger and confirm the symlink still resolves correctly
sudo udevadm trigger --subsystem-match=block
ls -l /dev/backup-drive
```

Then send the mission for grading:

```bash
astrona submit -c sections/section-010/module-04/labs/lab-01
```

---

## Command Summary

The rule file `/etc/udev/rules.d/99-backup-drive.rules` holds the two lines from Step 3. The commands:

```bash
lsblk
udevadm info --query=all --name=/dev/vdb
udevadm info --attribute-walk --name=/dev/vdb

sudo udevadm control --reload-rules
sudo udevadm trigger --subsystem-match=block

ls -l /dev/backup-drive /dev/backup-drive1
```
