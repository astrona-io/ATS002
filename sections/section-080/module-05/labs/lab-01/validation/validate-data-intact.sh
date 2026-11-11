#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Inspect protected state; user access checks select their target account explicitly.
sudo -n bash <<'GRADER_ROOT'
# Confirms the filesystem mounts and the original files are still there.

set -u

DISK_ID=/dev/disk/by-id/virtio-lab086-data001

if [[ ! -e "$DISK_ID" ]]; then
  echo "FAIL: data - $DISK_ID not found"
  exit 1
fi

BASEDEV=$(readlink -f "$DISK_ID")
P1="${BASEDEV}1"
MNT=/mnt/lab086-check

if findmnt -rn -S "$P1" >/dev/null 2>&1; then
  echo "FAIL: data - $P1 is still mounted, unmount it first"
  exit 1
fi

sudo mkdir -p "$MNT"
if ! sudo mount -o ro "$P1" "$MNT" 2>/dev/null; then
  echo "FAIL: data - could not mount $P1"
  exit 1
fi

A=$(cat "$MNT/marker.txt" 2>/dev/null || true)
B=$(cat "$MNT/logs/flight.log" 2>/dev/null || true)

sudo umount "$MNT"
sudo rmdir "$MNT" 2>/dev/null || true

if [[ "$A" != "cargo manifest 1 - LFCS lab-086, do not lose me" ]]; then
  echo "FAIL: data - marker.txt is missing or changed"
  exit 1
fi

if [[ "$B" != "flight log entry 7 - LFCS lab-086, do not lose me" ]]; then
  echo "FAIL: data - logs/flight.log is missing or changed"
  exit 1
fi

echo "PASS: the filesystem mounts and both original files are intact"
exit 0
GRADER_ROOT
ASTRONA_STUDENT_SCRIPT
