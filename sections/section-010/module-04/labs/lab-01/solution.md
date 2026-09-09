# Solution Walkthrough

Follow these steps to identify the disk, write a stable udev rule for it, and apply it live.

---

## Step 1: Identify the disk's current (unstable) device node

```bash
lsblk
```

Look for the disk that already has a single partition on it holding the backup data — note its current letter (e.g. `/dev/vdb`, `/dev/vdb1`).

---

## Step 2: Find a stable identifying attribute

```bash
udevadm info --query=all --name=/dev/vdb
```

If the serial isn't visible there, walk the device's full ancestry:

```bash
udevadm info --attribute-walk --name=/dev/vdb
```

Look for `ATTRS{serial}=="lab014-backup-drive"` — this is the identifier that stays with the physical disk no matter which `/dev/vdX` letter the kernel assigns it.

---

## Step 3: Draft the custom rule

```bash
sudo tee /etc/udev/rules.d/99-backup-drive.rules > /dev/null <<'EOF'
SUBSYSTEM=="block", ATTRS{serial}=="lab014-backup-drive", KERNEL=="vd[a-z]", SYMLINK+="backup-drive"
SUBSYSTEM=="block", ATTRS{serial}=="lab014-backup-drive", KERNEL=="vd[a-z]1", SYMLINK+="backup-drive1"
EOF
```

The first line matches the whole-disk device and creates `/dev/backup-drive`. The second line matches only its first partition and creates `/dev/backup-drive1` — the node the backup script actually needs to mount. Both match on `ATTRS{serial}`, the stable attribute from Step 2, rather than any kernel-assigned letter.

---

## Step 4: Load the new rule without rebooting

```bash
sudo udevadm control --reload-rules
sudo udevadm trigger --subsystem-match=block
```

`--reload-rules` tells the running `udevd` to re-read rule files from disk; `trigger` is still needed afterward to re-evaluate already-connected hardware against the newly-loaded rule.

---

## Step 5: Verify the symlinks appeared

```bash
ls -l /dev/backup-drive /dev/backup-drive1
```

Both should resolve as symlinks pointing at the disk's current letter and its first partition.

---

## Verification

```bash
udevadm info --query=all --name=/dev/backup-drive | grep -E 'DEVLINKS|ID_SERIAL'

ls -l /dev/backup-drive /dev/backup-drive1

# re-trigger and confirm the symlink still resolves correctly
sudo udevadm trigger --subsystem-match=block
ls -l /dev/backup-drive
```

---

## Command Summary

```bash
lsblk
udevadm info --query=all --name=/dev/vdb
udevadm info --attribute-walk --name=/dev/vdb

sudo tee /etc/udev/rules.d/99-backup-drive.rules > /dev/null <<'EOF'
SUBSYSTEM=="block", ATTRS{serial}=="lab014-backup-drive", KERNEL=="vd[a-z]", SYMLINK+="backup-drive"
SUBSYSTEM=="block", ATTRS{serial}=="lab014-backup-drive", KERNEL=="vd[a-z]1", SYMLINK+="backup-drive1"
EOF

sudo udevadm control --reload-rules
sudo udevadm trigger --subsystem-match=block

ls -l /dev/backup-drive /dev/backup-drive1
```

Once verified, run the local validation suite to pass the lab!
