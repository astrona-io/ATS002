#!/usr/bin/env bash
# Builds the disposable "data-001" stand-in disk for lab-081.
#
# This VM's OWN root filesystem and boot process are never touched by this
# lab -- the lab harness grades by SSHing into the VM and running a
# script, which cannot survive an actually-unbootable machine. Instead we
# attach a second, disposable virtio disk (extraDisks, serial
# "lab081-data001") and build a small standalone filesystem tree on it
# representing "data-001's disk": a small "root" partition carrying its
# own /etc (with a deliberately mistyped fstab UUID) and a small "data"
# partition that the fstab entry is supposed to mount. The student mounts
# the root partition, bind-mounts this VM's own /usr /bin /sbin /lib
# (read-only) into it for tools, chroots in, and fixes the typo.
#
# Never assume a raw /dev/vdX letter for the extraDisk -- resolve it via
# its `serial` through the kernel's stable /dev/disk/by-id/virtio-<serial>
# path instead, exactly as ATS004's lab-010 pattern does.

set -eu

DISK_ID=/dev/disk/by-id/virtio-lab081-data001

for i in $(seq 1 30); do
  [ -e "$DISK_ID" ] && break
  sleep 1
done
[ -e "$DISK_ID" ]

sudo udevadm settle --timeout=30 || true

BASEDEV=$(readlink -f "$DISK_ID")

# Partition the stand-in disk: a small "root" partition (data-001's own
# root filesystem) and a small "data" partition (the volume its fstab is
# supposed to mount).
sudo parted --script "$BASEDEV" \
  mklabel gpt \
  mkpart primary ext4 1MiB 1537MiB \
  mkpart primary ext4 1537MiB 100%

sudo partprobe "$BASEDEV" || true
sudo udevadm settle --timeout=30 || true

ROOT_PART="${BASEDEV}1"
DATA_PART="${BASEDEV}2"

for i in $(seq 1 30); do
  [ -e "$ROOT_PART" ] && [ -e "$DATA_PART" ] && break
  sleep 1
done
[ -e "$ROOT_PART" ]
[ -e "$DATA_PART" ]

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

mkfs_retry "$ROOT_PART" "DATA001ROOT"
mkfs_retry "$DATA_PART" "DATA001VOL"

REAL_UUID=$(sudo blkid -s UUID -o value "$DATA_PART")
# Mangle the last 4 hex characters to produce a plausible-looking, but
# wrong, UUID -- the same kind of stale/mistyped UUID that causes this
# exact real-world outage.
BAD_UUID="${REAL_UUID%????}dead"

BUILD=/mnt/lab081-build
sudo mkdir -p "$BUILD"
sudo mount "$ROOT_PART" "$BUILD"

sudo mkdir -p "$BUILD"/etc "$BUILD"/data "$BUILD"/dev "$BUILD"/proc "$BUILD"/sys \
  "$BUILD"/bin "$BUILD"/sbin "$BUILD"/lib "$BUILD"/usr "$BUILD"/run "$BUILD"/tmp
if [ -e /lib64 ]; then
  sudo mkdir -p "$BUILD"/lib64
fi

echo "data-001" | sudo tee "$BUILD/etc/hostname" >/dev/null

sudo tee "$BUILD/etc/fstab" >/dev/null <<EOF
# /etc/fstab: static file system information for data-001
UUID=$BAD_UUID  /data  ext4  defaults  0  2
EOF

sync
sudo umount "$BUILD"
sudo rmdir "$BUILD"

echo "lab-081 bootstrap complete."
echo "  data-001 root partition: $ROOT_PART (bad fstab UUID: $BAD_UUID)"
echo "  data-001 data partition: $DATA_PART (real UUID: $REAL_UUID)"

exit 0
