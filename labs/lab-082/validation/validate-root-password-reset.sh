#!/usr/bin/env bash
# Confirms root's password hash on the stand-in "data-001" disk was
# actually reset. Runs entirely from the primary VM, outside of any
# chroot -- mounts the stand-in disk read-only and checks /etc/shadow's
# root line has a non-empty hash field different from the bootstrap-
# seeded locked placeholder ("!"). Does not (and cannot, from outside)
# verify the plaintext password itself -- that's neither necessary nor
# feasible to check this way, and isn't the point of the exercise.

set -u

DISK_ID=/dev/disk/by-id/virtio-lab082-data001

if [[ ! -e "$DISK_ID" ]]; then
  echo "FAIL: root password reset - stand-in disk $DISK_ID not found"
  exit 1
fi

BASEDEV=$(readlink -f "$DISK_ID")

CHECK=/mnt/lab082-check
sudo mkdir -p "$CHECK"
if ! sudo mount -o ro "$BASEDEV" "$CHECK" 2>/dev/null; then
  echo "FAIL: root password reset - could not mount $BASEDEV read-only for inspection"
  exit 1
fi

SHADOW_LINE=""
if [[ -f "$CHECK/etc/shadow" ]]; then
  SHADOW_LINE=$(sudo grep '^root:' "$CHECK/etc/shadow" || true)
fi

sudo umount "$CHECK"
sudo rmdir "$CHECK" 2>/dev/null || true

if [[ -z "$SHADOW_LINE" ]]; then
  echo "FAIL: root password reset - no root entry found in /etc/shadow on the stand-in disk"
  exit 1
fi

HASH_FIELD=$(cut -d: -f2 <<<"$SHADOW_LINE")

if [[ -z "$HASH_FIELD" ]]; then
  echo "FAIL: root password reset - root's password hash field is empty"
  exit 1
fi

if [[ "$HASH_FIELD" == "!" || "$HASH_FIELD" == "!!" || "$HASH_FIELD" == "*" ]]; then
  echo "FAIL: root password reset - root's password hash field is still the locked bootstrap placeholder ($HASH_FIELD)"
  exit 1
fi

echo "PASS: root's password hash on the data-001 stand-in disk has been reset"
exit 0
