#!/usr/bin/env bash
set -euo pipefail
disk=$(readlink -f /dev/disk/by-id/virtio-lab085-data002)
sudo mkdir -p /mnt/repair
sudo mount "${disk}1" /mnt/repair
uuid=$(sudo blkid -s UUID -o value "${disk}2")
printf 'UUID=%s /data xfs defaults 0 2\n' "$uuid" | sudo tee /mnt/repair/etc/fstab
sudo umount /mnt/repair
