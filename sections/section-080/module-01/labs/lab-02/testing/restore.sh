#!/usr/bin/env bash
set -euo pipefail
disk=$(readlink -f /dev/disk/by-id/virtio-lab085-data002)
sudo mount "${disk}1" /mnt/repair
sudo cp /tmp/fstab.saved /mnt/repair/etc/fstab
sudo umount /mnt/repair
