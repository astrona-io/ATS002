#!/usr/bin/env bash
# Confirms the fstab typo on the stand-in "data-001" disk was actually
# fixed. Runs entirely from the primary VM, outside of any chroot --
# mounts the stand-in disk's root partition read-only and checks its
# /etc/fstab now references the data partition's real, current UUID
# instead of the deliberately mistyped one bootstrap seeded.

set -u

DISK_ID=/dev/disk/by-id/virtio-lab081-data001

if [[ ! -e "$DISK_ID" ]]; then
  echo "FAIL: fstab fixed - stand-in disk $DISK_ID not found"
  exit 1
fi

BASEDEV=$(readlink -f "$DISK_ID")
ROOT_PART="${BASEDEV}1"
DATA_PART="${BASEDEV}2"

if [[ ! -e "$ROOT_PART" || ! -e "$DATA_PART" ]]; then
  echo "FAIL: fstab fixed - expected partitions $ROOT_PART / $DATA_PART not found"
  exit 1
fi

REAL_UUID=$(sudo blkid -s UUID -o value "$DATA_PART" 2>/dev/null)
if [[ -z "$REAL_UUID" ]]; then
  echo "FAIL: fstab fixed - could not read UUID of $DATA_PART"
  exit 1
fi

CHECK=/mnt/lab081-check
sudo mkdir -p "$CHECK"
if ! sudo mount -o ro "$ROOT_PART" "$CHECK" 2>/dev/null; then
  echo "FAIL: fstab fixed - could not mount $ROOT_PART read-only for inspection"
  exit 1
fi

FSTAB_CONTENT=""
if [[ -f "$CHECK/etc/fstab" ]]; then
  FSTAB_CONTENT=$(cat "$CHECK/etc/fstab")
fi

sudo umount "$CHECK"
sudo rmdir "$CHECK" 2>/dev/null || true

if [[ -z "$FSTAB_CONTENT" ]]; then
  echo "FAIL: fstab fixed - /etc/fstab is missing or empty on $ROOT_PART"
  exit 1
fi

if ! grep -q "$REAL_UUID" <<<"$FSTAB_CONTENT"; then
  echo "FAIL: fstab fixed - /etc/fstab on $ROOT_PART does not reference the data partition's real UUID ($REAL_UUID)"
  exit 1
fi

if ! grep -Eq "UUID=$REAL_UUID[[:space:]]+/data[[:space:]]+ext4" <<<"$FSTAB_CONTENT"; then
  echo "FAIL: fstab fixed - the corrected UUID is present, but not as a valid /data ext4 line"
  exit 1
fi

echo "PASS: /etc/fstab on the data-001 stand-in disk now references the correct UUID ($REAL_UUID) for /data"
exit 0
