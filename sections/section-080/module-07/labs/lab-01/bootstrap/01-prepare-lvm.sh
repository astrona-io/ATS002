#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Builds the STARTING state for lab-088 (LVM recovery): a spare disk used as
# one LVM physical volume, a volume group cargo_vg, one logical volume deck
# with an ext4 filesystem holding known files. The group is then switched
# off and the first megabyte of the disk (LVM label and metadata area) is
# zeroed. The text backup in /etc/lvm/backup stays, so the student can
# restore the layout. The data area starts after the first megabyte and is
# untouched.
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
echo "cargo manifest 1 - LFCS lab-088, do not lose me" | sudo tee "$MOUNT_POINT/marker.txt" >/dev/null
sudo mkdir -p "$MOUNT_POINT/logs"
echo "flight log entry 7 - LFCS lab-088, do not lose me" | sudo tee "$MOUNT_POINT/logs/flight.log" >/dev/null
sync
sudo umount "$MOUNT_POINT"
rmdir "$MOUNT_POINT"

# Make sure the text backup is current before the disaster.
sudo vgcfgbackup cargo_vg
sync

# The disaster: switch the group off, then zero the first megabyte.
sudo vgchange -an cargo_vg
sudo udevadm settle --timeout=30 || true
sudo dd if=/dev/zero of="$TARGET_DISK" bs=1M count=1 conv=notrunc status=none
sync
sudo udevadm settle --timeout=10 || true
sudo pvscan --cache >/dev/null 2>&1 || true
ASTRONA_STUDENT_SCRIPT
