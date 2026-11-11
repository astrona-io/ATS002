#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Builds the starting state for the LVM recovery playground: a spare disk
# used as one LVM physical volume, a volume group cargo_vg, one logical
# volume deck with an ext4 filesystem and two known files. Nothing is
# broken here.
#
# The disk is found by its virtio serial, never by a device letter. The VM
# root disk is not touched, so the machine stays reachable over SSH.

set -eu

DISK_ID=/dev/disk/by-id/virtio-lab088-pv001

for i in $(seq 1 30); do
  [ -e "$DISK_ID" ] && break
  sleep 1
done
[ -e "$DISK_ID" ]

if ! command -v pvcreate >/dev/null 2>&1; then
  sudo apt-get update -qq || true
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq lvm2
fi

sudo udevadm settle --timeout=30 || true

TARGET_DISK=$(readlink -f "$DISK_ID")

sudo wipefs -a "$TARGET_DISK"
sudo pvcreate -y "$TARGET_DISK"
sudo vgcreate cargo_vg "$TARGET_DISK"
sudo lvcreate -y -n deck -L 400M cargo_vg
sudo udevadm settle --timeout=30 || true

sudo mkfs.ext4 -F -L DECK /dev/cargo_vg/deck

MOUNT_POINT=$(mktemp -d)
sudo mount /dev/cargo_vg/deck "$MOUNT_POINT"
echo "cargo manifest 1 - LFCS playground, do not lose me" | sudo tee "$MOUNT_POINT/marker.txt" >/dev/null
sudo mkdir -p "$MOUNT_POINT/logs"
echo "flight log entry 7 - LFCS playground, do not lose me" | sudo tee "$MOUNT_POINT/logs/flight.log" >/dev/null
sync
sudo umount "$MOUNT_POINT"
rmdir "$MOUNT_POINT"

# LVM writes /etc/lvm/backup/cargo_vg on its own; this makes sure it is current.
sudo vgcfgbackup cargo_vg
sync
ASTRONA_STUDENT_SCRIPT
