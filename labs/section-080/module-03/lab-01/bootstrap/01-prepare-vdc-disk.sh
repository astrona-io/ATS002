#!/usr/bin/env bash
# Prepares the secondary GPT disk for lab-083 (partition table backup and
# recovery). This scenario needs no safety adaptation -- it operates
# entirely on a non-root secondary disk, so the VM stays fully
# SSH-reachable throughout. This script only builds the STARTING state
# (two real ext4 partitions with marker files) -- the destructive
# zap/restore cycle is the student's job, not bootstrap's.
#
# Never assume a raw /dev/vdX letter -- resolve the extraDisk via its
# `serial` through /dev/disk/by-id/virtio-<serial>, exactly as ATS004's
# lab-010 pattern does, since extraDisks are not guaranteed to land on
# any particular device letter.

set -eu

DISK_ID=/dev/disk/by-id/virtio-lab083-vdc

for i in $(seq 1 30); do
  [ -e "$DISK_ID" ] && break
  sleep 1
done
[ -e "$DISK_ID" ]

sudo udevadm settle --timeout=30 || true

BASEDEV=$(readlink -f "$DISK_ID")

sudo parted --script "$BASEDEV" \
  mklabel gpt \
  mkpart primary ext4 1MiB 1025MiB \
  mkpart primary ext4 1025MiB 100%

sudo partprobe "$BASEDEV" || true
sudo udevadm settle --timeout=30 || true

P1="${BASEDEV}1"
P2="${BASEDEV}2"

for i in $(seq 1 30); do
  [ -e "$P1" ] && [ -e "$P2" ] && break
  sleep 1
done
[ -e "$P1" ]
[ -e "$P2" ]

mkfs_retry() {
  local dev="$1"
  local label="$2"
  for i in $(seq 1 10); do
    if sudo mkfs.ext4 -F -L "$label" "$dev"; then
      return 0
    fi
    echo "mkfs.ext4 on $dev busy, retrying ($i/10)..." >&2
    sudo udevadm settle --timeout=5 || true
    sleep 2
  done
  echo "mkfs.ext4 on $dev failed after retries" >&2
  return 1
}

mkfs_retry "$P1" "VDC1"
mkfs_retry "$P2" "VDC2"

sudo mkdir -p /mnt/vdc1 /mnt/vdc2
sudo mount "$P1" /mnt/vdc1
echo "vdc1 original data - LFCS lab-083, do not lose me" | sudo tee /mnt/vdc1/marker.txt >/dev/null
sudo umount /mnt/vdc1
sudo rmdir /mnt/vdc1

sudo mount "$P2" /mnt/vdc2
echo "vdc2 original data - LFCS lab-083, do not lose me" | sudo tee /mnt/vdc2/marker.txt >/dev/null
sudo umount /mnt/vdc2
sudo rmdir /mnt/vdc2

echo "lab-083 bootstrap complete. Secondary disk: $BASEDEV ($P1, $P2)"

exit 0
