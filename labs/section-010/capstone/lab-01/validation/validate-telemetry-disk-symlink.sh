#!/usr/bin/env bash
# Confirms a custom udev rule under /etc/udev/rules.d/ creates a
# /dev/telemetry-disk symlink that resolves to the actual disk carrying
# serial "lab010-telemetry" -- ground-truthed via the always-present
# /dev/disk/by-id/virtio-<serial> path rather than a raw /dev/vdX guess, so
# this holds regardless of which letter the kernel happened to assign.

set -u

SERIAL="lab010-telemetry"
BYID="/dev/disk/by-id/virtio-${SERIAL}"

if [[ ! -e "$BYID" ]]; then
  echo "FAIL: telemetry disk symlink - expected disk not found at $BYID"
  exit 1
fi

expected_disk=$(readlink -f "$BYID")

if ! grep -rq 'telemetry-disk' /etc/udev/rules.d/ 2>/dev/null; then
  echo "FAIL: telemetry disk symlink - no custom rule under /etc/udev/rules.d/ mentions telemetry-disk"
  exit 1
fi

if [[ ! -e /dev/telemetry-disk ]]; then
  echo "FAIL: telemetry disk symlink - /dev/telemetry-disk does not exist"
  exit 1
fi

actual_disk=$(readlink -f /dev/telemetry-disk)
if [[ "$actual_disk" != "$expected_disk" ]]; then
  echo "FAIL: telemetry disk symlink - /dev/telemetry-disk resolves to '$actual_disk', expected '$expected_disk'"
  exit 1
fi

echo "PASS: /dev/telemetry-disk -> $actual_disk (serial $SERIAL)"
exit 0
