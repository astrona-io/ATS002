#!/usr/bin/env bash
# Grades from OUTSIDE any chroot: re-mount the stand-in disk's root
# partition read-only and confirm /etc/fstab's /data entry now declares the
# data partition's REAL filesystem type (xfs), matching blkid - so a
# boot-time `mount -a` would succeed. The UUID/device must still be the
# correct one (it was never wrong).
set -u

fail() { echo "FAIL: $1"; exit 1; }

DISK_ID=/dev/disk/by-id/virtio-lab085-data002
[ -e "$DISK_ID" ] || fail "stand-in disk (serial lab085-data002) not found"
BASEDEV=$(readlink -f "$DISK_ID")
ROOT_PART="${BASEDEV}1"
DATA_PART="${BASEDEV}2"
[ -b "$ROOT_PART" ] && [ -b "$DATA_PART" ] || fail "stand-in partitions not present"

REAL_TYPE=$(sudo blkid -s TYPE -o value "$DATA_PART" 2>/dev/null)
REAL_UUID=$(sudo blkid -s UUID -o value "$DATA_PART" 2>/dev/null)
[ "$REAL_TYPE" = "xfs" ] || fail "data partition is '$REAL_TYPE', expected xfs (bootstrap issue)"

MP=$(mktemp -d)
sudo mount -o ro "$ROOT_PART" "$MP" || fail "could not mount stand-in root partition"
line="$(grep -E '[[:space:]]/data[[:space:]]' "$MP/etc/fstab" 2>/dev/null | grep -v '^[[:space:]]*#')"
sudo umount "$MP"; rmdir "$MP"

[ -n "$line" ] || fail "no /data entry in the stand-in /etc/fstab"

# Field 3 (fs type) must now be xfs.
fstype=$(awk '{print $3}' <<< "$line")
[ "$fstype" = "xfs" ] || fail "/data fstab entry still declares type '$fstype', expected 'xfs' -- got: $line"

# Field 1 must still identify the correct device (UUID or a stable path).
spec=$(awk '{print $1}' <<< "$line")
case "$spec" in
  UUID=$REAL_UUID) : ;;
  /dev/disk/by-*|/dev/disk/by-*/*) : ;;
  *) fail "/data entry's device spec '$spec' no longer matches the real data partition (UUID=$REAL_UUID)";;
esac

echo "PASS: /etc/fstab /data entry now declares xfs, matching blkid; device spec unchanged"
exit 0
