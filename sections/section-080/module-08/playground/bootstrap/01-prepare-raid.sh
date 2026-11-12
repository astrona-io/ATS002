#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Builds the starting state for the software RAID playground: a healthy
# RAID 1 array /dev/md/cargo on two spare disks (serials lab089-raid-a and
# lab089-raid-b) with an ext4 filesystem and two known files. A third blank
# disk (lab089-raid-c) is the spare. Nothing is broken here.
#
# Disks are found by their virtio serials, never by a device letter. The VM
# root disk is not touched, so the machine stays reachable over SSH.

set -eu

DISK_A_ID=/dev/disk/by-id/virtio-lab089-raid-a
DISK_B_ID=/dev/disk/by-id/virtio-lab089-raid-b
DISK_C_ID=/dev/disk/by-id/virtio-lab089-raid-c

for id in "$DISK_A_ID" "$DISK_B_ID" "$DISK_C_ID"; do
  for i in $(seq 1 30); do
    [ -e "$id" ] && break
    sleep 1
  done
  [ -e "$id" ]
done

if ! command -v mdadm >/dev/null 2>&1; then
  sudo apt-get update -qq || true
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq mdadm
fi

sudo modprobe raid1 || true
sudo udevadm settle --timeout=30 || true

DISK_A=$(readlink -f "$DISK_A_ID")
DISK_B=$(readlink -f "$DISK_B_ID")
DISK_C=$(readlink -f "$DISK_C_ID")

sudo wipefs -a "$DISK_A" "$DISK_B" "$DISK_C"

sudo mdadm --create /dev/md/cargo --run --level=1 --raid-devices=2 \
  --metadata=1.2 --name=cargo "$DISK_A" "$DISK_B"
sudo mdadm --wait /dev/md/cargo || true
sudo udevadm settle --timeout=30 || true

sudo mkfs.ext4 -F -L CARGO /dev/md/cargo

MOUNT_POINT=$(mktemp -d)
sudo mount /dev/md/cargo "$MOUNT_POINT"
echo "cargo manifest 1 - LFCS playground, do not lose me" | sudo tee "$MOUNT_POINT/marker.txt" >/dev/null
sudo mkdir -p "$MOUNT_POINT/logs"
echo "flight log entry 7 - LFCS playground, do not lose me" | sudo tee "$MOUNT_POINT/logs/flight.log" >/dev/null
sync
sudo umount "$MOUNT_POINT"
rmdir "$MOUNT_POINT"
sync
ASTRONA_STUDENT_SCRIPT
