#!/usr/bin/env bash
# Bootstrap: waits for the extraDisk (serial lab010-telemetry) to fully
# settle in the guest before the student starts working. The disk itself
# is intentionally left raw/blank -- the task is only to give it a stable
# udev symlink, not to partition or format it.
#
# As with other labs using extraDisks, astrona-cli does not guarantee this
# disk lands on any particular /dev/vdX letter, so this (and validation)
# resolve it via the always-present /dev/disk/by-id/virtio-<serial> path.

set -eu

DISK=/dev/disk/by-id/virtio-lab010-telemetry

for i in $(seq 1 30); do
  [ -e "$DISK" ] && break
  sleep 1
done

sudo udevadm settle --timeout=30 || true
