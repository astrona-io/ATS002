#!/usr/bin/env bash
# Confirms a custom udev rule under /etc/udev/rules.d/ creates /dev/backup-drive
# and /dev/backup-drive1 symlinks that resolve to the actual disk/partition
# carrying serial "lab014-backup-drive" -- ground-truthed via the always-present
# /dev/disk/by-id/virtio-<serial> path rather than a raw /dev/vdX guess, so
# this holds regardless of which letter the kernel happened to assign.

set -u

SERIAL="lab014-backup-drive"
BYID="/dev/disk/by-id/virtio-${SERIAL}"

if [[ ! -e "$BYID" ]]; then
  echo "FAIL: udev symlinks - expected disk not found at $BYID"
  exit 1
fi

expected_disk=$(readlink -f "$BYID")
expected_part="${expected_disk}1"

if ! grep -rq 'backup-drive' /etc/udev/rules.d/ 2>/dev/null; then
  echo "FAIL: udev symlinks - no custom rule under /etc/udev/rules.d/ mentions backup-drive"
  exit 1
fi

if [[ ! -e /dev/backup-drive ]]; then
  echo "FAIL: udev symlinks - /dev/backup-drive does not exist"
  exit 1
fi

actual_disk=$(readlink -f /dev/backup-drive)
if [[ "$actual_disk" != "$expected_disk" ]]; then
  echo "FAIL: udev symlinks - /dev/backup-drive resolves to '$actual_disk', expected '$expected_disk'"
  exit 1
fi

if [[ ! -e /dev/backup-drive1 ]]; then
  echo "FAIL: udev symlinks - /dev/backup-drive1 does not exist"
  exit 1
fi

actual_part=$(readlink -f /dev/backup-drive1)
if [[ "$actual_part" != "$expected_part" ]]; then
  echo "FAIL: udev symlinks - /dev/backup-drive1 resolves to '$actual_part', expected '$expected_part'"
  exit 1
fi

echo "PASS: /dev/backup-drive -> $actual_disk and /dev/backup-drive1 -> $actual_part"
exit 0
