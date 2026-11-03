#!/usr/bin/env bash
# Builds the disposable "data-001" stand-in disk for lab-082.
#
# Same safety rationale as lab-081: this VM's own root filesystem and
# boot process are never touched, because the grading harness needs SSH
# to survive. Instead, a second disposable virtio disk (extraDisks,
# serial "lab082-data001") is formatted with a small standalone
# filesystem tree carrying its own /etc/shadow -- root's password
# field seeded to "!" (locked, no password set), representing a
# genuinely locked-out account. The student mounts it, bind-mounts this
# VM's own /usr /bin /sbin /lib (read-only) in for tools, bind-mounts
# /dev /proc /sys, chroots in, and resets root's password hash.
#
# Never assume a raw /dev/vdX letter -- resolve the extraDisk via its
# `serial` through /dev/disk/by-id/virtio-<serial> instead.

set -eu

DISK_ID=/dev/disk/by-id/virtio-lab082-data001

for i in $(seq 1 30); do
  [ -e "$DISK_ID" ] && break
  sleep 1
done
[ -e "$DISK_ID" ]

sudo udevadm settle --timeout=30 || true

BASEDEV=$(readlink -f "$DISK_ID")

for i in $(seq 1 10); do
  if sudo mkfs.ext4 -F -L DATA001ROOT "$BASEDEV"; then
    break
  fi
  echo "mkfs.ext4 on $BASEDEV busy, retrying..." >&2
  sudo udevadm settle --timeout=5 || true
  sleep 2
done

BUILD=/mnt/lab082-build
sudo mkdir -p "$BUILD"
sudo mount "$BASEDEV" "$BUILD"

sudo mkdir -p "$BUILD"/etc "$BUILD"/dev "$BUILD"/proc "$BUILD"/sys \
  "$BUILD"/bin "$BUILD"/sbin "$BUILD"/lib "$BUILD"/usr "$BUILD"/run "$BUILD"/tmp "$BUILD"/root
if [ -e /lib64 ]; then
  sudo mkdir -p "$BUILD"/lib64
fi

echo "data-001" | sudo tee "$BUILD/etc/hostname" >/dev/null

# Minimal, plausible /etc/passwd and /etc/group -- not required for the
# hash-splice technique this lab teaches, but included for realism.
sudo tee "$BUILD/etc/passwd" >/dev/null <<'EOF'
root:x:0:0:root:/root:/bin/bash
EOF

sudo tee "$BUILD/etc/group" >/dev/null <<'EOF'
root:x:0:
EOF

# Seed root's shadow entry as locked ("!" -- a standard convention for
# "no usable password set / account locked"), which is this lab's stand-in
# for "the root password is lost." The student's job is to replace this
# field with a real password hash.
sudo tee "$BUILD/etc/shadow" >/dev/null <<'EOF'
root:!:19700:0:99999:7:::
EOF
sudo chmod 600 "$BUILD/etc/shadow"

sync
sudo umount "$BUILD"
sudo rmdir "$BUILD"

echo "lab-082 bootstrap complete. data-001 root filesystem: $BASEDEV (root account locked)"

exit 0
