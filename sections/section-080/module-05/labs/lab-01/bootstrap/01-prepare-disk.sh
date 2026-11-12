#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Builds the STARTING state for lab-086 (filesystem check and repair): a
# spare disk with one GPT partition and an ext4 filesystem holding known
# files, whose PRIMARY superblock has then been zeroed. The backup
# superblocks are untouched, so the student can repair it.
#
# The disk is found by its virtio serial, never by a device letter. The VM
# root disk is not touched, so the machine stays reachable over SSH.

set -eu

DISK_ID=/dev/disk/by-id/virtio-lab086-data001

for i in $(seq 1 30); do
  [ -e "$DISK_ID" ] && break
  sleep 1
done
[ -e "$DISK_ID" ]

sudo udevadm settle --timeout=30 || true

BASEDEV=$(readlink -f "$DISK_ID")

sudo parted --script "$BASEDEV" \
  mklabel gpt \
  mkpart primary ext4 1MiB 100%

sudo partprobe "$BASEDEV" || true
sudo udevadm settle --timeout=30 || true

P1="${BASEDEV}1"

for i in $(seq 1 30); do
  [ -e "$P1" ] && break
  sleep 1
done
[ -e "$P1" ]

# Fixed 4096-byte blocks, so the first backup superblock is always block
# 32768 on a filesystem of this size.
for i in $(seq 1 10); do
  if sudo mkfs.ext4 -F -b 4096 -L CARGO "$P1"; then
    break
  fi
  echo "mkfs.ext4 on $P1 busy, retrying ($i/10)..." >&2
  sudo udevadm settle --timeout=5 || true
  sleep 2
  [ "$i" -lt 10 ] || exit 1
done

MNT=$(mktemp -d)
sudo mount "$P1" "$MNT"
echo "cargo manifest 1 - LFCS lab-086, do not lose me" | sudo tee "$MNT/marker.txt" >/dev/null
sudo mkdir -p "$MNT/logs"
echo "flight log entry 7 - LFCS lab-086, do not lose me" | sudo tee "$MNT/logs/flight.log" >/dev/null
sync
sudo umount "$MNT"
rmdir "$MNT"

# The disaster: zero the primary ext4 superblock (1024 bytes at byte offset
# 1024 of the partition). Backup copies further into the partition stay.
sudo dd if=/dev/zero of="$P1" bs=1024 seek=1 count=1 conv=notrunc status=none
sync
sudo udevadm settle --timeout=10 || true
ASTRONA_STUDENT_SCRIPT
