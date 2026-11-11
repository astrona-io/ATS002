#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Inspect protected state; user access checks select their target account explicitly.
sudo -n bash <<'GRADER_ROOT'
# Confirms the partition on the spare disk has a readable ext4 superblock again.

set -u

DISK_ID=/dev/disk/by-id/virtio-lab086-data001

if [[ ! -e "$DISK_ID" ]]; then
  echo "FAIL: superblock - $DISK_ID not found"
  exit 1
fi

BASEDEV=$(readlink -f "$DISK_ID")
P1="${BASEDEV}1"

if [[ ! -b "$P1" ]]; then
  echo "FAIL: superblock - $P1 does not exist"
  exit 1
fi

if ! sudo dumpe2fs -h "$P1" >/dev/null 2>&1; then
  echo "FAIL: superblock - dumpe2fs cannot read a superblock on $P1"
  exit 1
fi

TYPE=$(sudo blkid -o value -s TYPE "$P1" 2>/dev/null || true)
if [[ "$TYPE" != "ext4" ]]; then
  echo "FAIL: superblock - blkid reports type '$TYPE' on $P1, expected ext4"
  exit 1
fi

echo "PASS: $P1 has a readable ext4 superblock again"
exit 0
GRADER_ROOT
ASTRONA_STUDENT_SCRIPT
