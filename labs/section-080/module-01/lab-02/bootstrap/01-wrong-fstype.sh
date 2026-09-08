#!/usr/bin/env bash
# Builds the disposable "data-002" stand-in disk for lab-085.
#
# Companion to lab-081 (mistyped UUID). Here the fstab entry's *device
# identifier is correct* -- what is wrong is the filesystem TYPE field: the
# data partition is xfs, but the entry says ext4. On a real boot,
# `mount -a` would fail with:
#     mount: /data: wrong fs type, bad option, bad superblock on /dev/...
#
# The student mounts the stand-in root partition, bind-mounts this VM's own
# userland + /dev,/proc,/sys, chroots in, cross-checks `blkid` (TYPE="xfs"),
# and corrects the third field of the fstab line to `xfs`. The device/UUID
# is left alone -- it was never wrong.
#
# Resolve the extraDisk via its serial, never a raw /dev/vdX letter.
set -eu

sudo apt-get update -qq && sudo apt-get install -y -qq xfsprogs

DISK_ID=/dev/disk/by-id/virtio-lab085-data002
for i in $(seq 1 30); do [ -e "$DISK_ID" ] && break; sleep 1; done
[ -e "$DISK_ID" ]
sudo udevadm settle --timeout=30 || true
BASEDEV=$(readlink -f "$DISK_ID")

sudo parted --script "$BASEDEV" \
  mklabel gpt \
  mkpart primary ext4 1MiB 1025MiB \
  mkpart primary xfs  1025MiB 100%
sudo partprobe "$BASEDEV" || true
sudo udevadm settle --timeout=30 || true

ROOT_PART="${BASEDEV}1"
DATA_PART="${BASEDEV}2"
for i in $(seq 1 30); do [ -e "$ROOT_PART" ] && [ -e "$DATA_PART" ] && break; sleep 1; done
[ -e "$ROOT_PART" ]; [ -e "$DATA_PART" ]

retry() { local i; for i in $(seq 1 10); do "$@" && return 0; sudo udevadm settle --timeout=5 || true; sleep 2; done; return 1; }

retry sudo mkfs.ext4 -F -L DATA002ROOT "$ROOT_PART"
retry sudo mkfs.xfs  -f -L DATA002VOL  "$DATA_PART"

REAL_UUID=$(sudo blkid -s UUID -o value "$DATA_PART")
REAL_TYPE=$(sudo blkid -s TYPE -o value "$DATA_PART")   # xfs
echo "data partition: UUID=$REAL_UUID TYPE=$REAL_TYPE"

BUILD=/mnt/lab085-build
sudo mkdir -p "$BUILD"
sudo mount "$ROOT_PART" "$BUILD"
sudo mkdir -p "$BUILD"/etc "$BUILD"/data "$BUILD"/dev "$BUILD"/proc "$BUILD"/sys \
  "$BUILD"/bin "$BUILD"/sbin "$BUILD"/lib "$BUILD"/usr "$BUILD"/run "$BUILD"/tmp
[ -e /lib64 ] && sudo mkdir -p "$BUILD"/lib64

echo "data-002" | sudo tee "$BUILD/etc/hostname" >/dev/null

# Correct device, WRONG type (ext4 instead of xfs).
sudo tee "$BUILD/etc/fstab" >/dev/null <<EOF
# /etc/fstab: static file system information for data-002
UUID=$REAL_UUID  /data  ext4  defaults  0  2
EOF

sync
sudo umount "$BUILD"
sudo rmdir "$BUILD"

echo "lab-085 bootstrap complete."
echo "  data-002 root partition: $ROOT_PART"
echo "  data-002 data partition: $DATA_PART  (real type: $REAL_TYPE; fstab wrongly says ext4)"
exit 0
