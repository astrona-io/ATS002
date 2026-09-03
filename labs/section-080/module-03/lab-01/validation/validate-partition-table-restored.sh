#!/usr/bin/env bash
# Confirms the secondary disk currently has its 2 original partitions
# back -- the partition-table layer of the restore. Resolves the disk via
# its stable serial-based by-id path, never a raw /dev/vdX guess.

set -u

DISK_ID=/dev/disk/by-id/virtio-lab083-vdc

if [[ ! -e "$DISK_ID" ]]; then
  echo "FAIL: partition table restored - $DISK_ID not found"
  exit 1
fi

BASEDEV=$(readlink -f "$DISK_ID")
P1="${BASEDEV}1"
P2="${BASEDEV}2"

if [[ ! -b "$P1" ]]; then
  echo "FAIL: partition table restored - $P1 does not exist (partition 1 missing)"
  exit 1
fi

if [[ ! -b "$P2" ]]; then
  echo "FAIL: partition table restored - $P2 does not exist (partition 2 missing)"
  exit 1
fi

echo "PASS: $BASEDEV has both original partitions present ($P1, $P2)"
exit 0
