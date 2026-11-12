#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Inspect protected state; user access checks select their target account explicitly.
sudo -n bash <<'GRADER_ROOT'
# Confirms the array mounts and the original files are still there.

set -u

ARRAY=/dev/md/cargo
MOUNT_POINT=/mnt/lab089-check

if [[ ! -e "$ARRAY" ]]; then
  echo "FAIL: data - $ARRAY does not exist"
  exit 1
fi

if findmnt -rn -S "$(readlink -f "$ARRAY")" >/dev/null 2>&1; then
  echo "FAIL: data - the array is still mounted, unmount it first"
  exit 1
fi

sudo mkdir -p "$MOUNT_POINT"
if ! sudo mount -o ro "$ARRAY" "$MOUNT_POINT" 2>/dev/null; then
  echo "FAIL: data - could not mount $ARRAY"
  exit 1
fi

MARKER=$(cat "$MOUNT_POINT/marker.txt" 2>/dev/null || true)
FLIGHT=$(cat "$MOUNT_POINT/logs/flight.log" 2>/dev/null || true)

sudo umount "$MOUNT_POINT"
sudo rmdir "$MOUNT_POINT" 2>/dev/null || true

if [[ "$MARKER" != "cargo manifest 1 - LFCS lab-089, do not lose me" ]]; then
  echo "FAIL: data - marker.txt is missing or changed"
  exit 1
fi

if [[ "$FLIGHT" != "flight log entry 7 - LFCS lab-089, do not lose me" ]]; then
  echo "FAIL: data - logs/flight.log is missing or changed"
  exit 1
fi

echo "PASS: the array mounts and both original files are intact"
exit 0
GRADER_ROOT
ASTRONA_STUDENT_SCRIPT
