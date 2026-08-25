#!/usr/bin/env bash
# Bootstrap: partitions and formats the extraDisk (serial lab014-backup-drive)
# with a single ext4 partition, simulating an already-in-use external backup
# drive the student must give a stable udev-based name to.
#
# Resolved via /dev/disk/by-id/virtio-<serial> rather than a raw /dev/vdX
# letter, since astrona-cli's extraDisks are not guaranteed to land on any
# particular device letter.

set -eu

DISK=/dev/disk/by-id/virtio-lab014-backup-drive

for i in $(seq 1 30); do
  [ -e "$DISK" ] && break
  sleep 1
done

sudo udevadm settle --timeout=30 || true

REALDEV=$(readlink -f "$DISK")

sudo parted -s "$REALDEV" mklabel gpt
sudo parted -s "$REALDEV" mkpart primary ext4 1MiB 100%
sudo udevadm settle --timeout=30 || true

PART="${REALDEV}1"
for i in $(seq 1 15); do
  [ -e "$PART" ] && break
  sleep 1
done

mkfs_retry() {
  local dev="$1"
  for i in $(seq 1 10); do
    if sudo mkfs.ext4 -F "$dev"; then
      return 0
    fi
    echo "mkfs.ext4 on $dev busy, retrying ($i/10)..." >&2
    sudo udevadm settle --timeout=5 || true
    sleep 2
  done
  echo "mkfs.ext4 on $dev failed after retries" >&2
  return 1
}

mkfs_retry "$PART"
