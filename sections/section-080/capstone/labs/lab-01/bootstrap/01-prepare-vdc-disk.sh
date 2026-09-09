#!/usr/bin/env bash
# Builds the secondary disk for this capstone's "partition table already
# wiped" half. Unlike lab-083 (where the student creates their own
# backup before simulating a disaster), this capstone starts further
# into the incident: a backup already exists on disk and the disaster
# has already happened by the time the student logs in -- the "you get
# paged after it already went wrong" framing this capstone uses. This
# whole scenario needs no safety adaptation of its own: it operates
# entirely on this non-root secondary disk, so the VM stays fully
# SSH-reachable throughout.
#
# Never assume a raw /dev/vdX letter -- resolve the extraDisk via its
# `serial` through /dev/disk/by-id/virtio-<serial>, exactly as lab-083's
# bootstrap does.

set -eu

DISK_ID=/dev/disk/by-id/virtio-lab080-vdc

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
echo "vdc1 original data - LFCS lab-080, do not lose me" | sudo tee /mnt/vdc1/marker.txt >/dev/null
sudo umount /mnt/vdc1
sudo rmdir /mnt/vdc1

sudo mount "$P2" /mnt/vdc2
echo "vdc2 original data - LFCS lab-080, do not lose me" | sudo tee /mnt/vdc2/marker.txt >/dev/null
sudo umount /mnt/vdc2
sudo rmdir /mnt/vdc2

# Take the "already on file" backup a healthy on-call rotation would
# have had in place before anything went wrong -- this capstone starts
# at the point of already being paged, not at the point of taking the
# backup (that discipline is Module 3 / lab-083's own lesson).
sudo sgdisk --backup=/root/vdc-ptable-backup.bin "$BASEDEV"

# Simulate the disaster having already happened, before the student
# ever logged in.
sudo sgdisk --zap-all "$BASEDEV"
sudo partprobe "$BASEDEV" || true
sudo udevadm settle --timeout=30 || true

echo "lab-080 bootstrap (secondary disk) complete."
echo "  Secondary disk: $BASEDEV, partition table already wiped"
echo "  Backup on file: /root/vdc-ptable-backup.bin"

exit 0
