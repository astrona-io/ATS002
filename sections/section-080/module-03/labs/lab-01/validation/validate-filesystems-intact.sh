#!/usr/bin/env bash
# Confirms the filesystem layer is separately intact after the restore --
# not just that partitions reappeared, but that each one mounts cleanly
# and its original marker file (written by bootstrap before the
# disaster/restore cycle) is still readable with its original content.

set -u

DISK_ID=/dev/disk/by-id/virtio-lab083-vdc

if [[ ! -e "$DISK_ID" ]]; then
  echo "FAIL: filesystems intact - $DISK_ID not found"
  exit 1
fi

BASEDEV=$(readlink -f "$DISK_ID")
P1="${BASEDEV}1"
P2="${BASEDEV}2"

check_partition() {
  local part="$1"
  local expected="$2"
  local mnt="$3"

  if [[ ! -b "$part" ]]; then
    echo "FAIL: filesystems intact - $part does not exist"
    return 1
  fi

  if ! sudo fsck -n "$part" >/dev/null 2>&1; then
    echo "FAIL: filesystems intact - fsck -n reported errors on $part"
    return 1
  fi

  sudo mkdir -p "$mnt"
  if ! sudo mount -o ro "$part" "$mnt" 2>/dev/null; then
    echo "FAIL: filesystems intact - could not mount $part"
    return 1
  fi

  local content=""
  if [[ -f "$mnt/marker.txt" ]]; then
    content=$(cat "$mnt/marker.txt")
  fi

  sudo umount "$mnt"
  sudo rmdir "$mnt" 2>/dev/null || true

  if [[ "$content" != "$expected" ]]; then
    echo "FAIL: filesystems intact - $part's marker.txt content does not match the original ('$content' != '$expected')"
    return 1
  fi

  return 0
}

check_partition "$P1" "vdc1 original data - LFCS lab-083, do not lose me" /mnt/lab083-check1 || exit 1
check_partition "$P2" "vdc2 original data - LFCS lab-083, do not lose me" /mnt/lab083-check2 || exit 1

echo "PASS: both partitions pass fsck -n cleanly and their original marker files are intact"
exit 0
