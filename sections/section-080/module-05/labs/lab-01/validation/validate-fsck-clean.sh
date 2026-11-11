#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Confirms a forced read-only check of the repaired filesystem finds no errors.

set -u

DISK_ID=/dev/disk/by-id/virtio-lab086-data001

if [[ ! -e "$DISK_ID" ]]; then
  echo "FAIL: fsck - $DISK_ID not found"
  exit 1
fi

BASEDEV=$(readlink -f "$DISK_ID")
P1="${BASEDEV}1"

if findmnt -rn -S "$P1" >/dev/null 2>&1; then
  echo "FAIL: fsck - $P1 is still mounted, unmount it first"
  exit 1
fi

if ! sudo fsck.ext4 -n -f "$P1" >/dev/null 2>&1; then
  echo "FAIL: fsck - fsck.ext4 -n -f still reports problems on $P1"
  exit 1
fi

echo "PASS: fsck.ext4 -n -f finds no errors on $P1"
exit 0
ASTRONA_STUDENT_SCRIPT
