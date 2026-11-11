#!/usr/bin/env bash
set -euo pipefail
disk=$(readlink -f /dev/disk/by-id/virtio-lab083-vdc)
sudo sgdisk --backup=/root/vdc-ptable-backup.bin "$disk"
sudo sgdisk --zap-all "$disk"
sudo sgdisk --load-backup=/root/vdc-ptable-backup.bin "$disk"
sudo partprobe "$disk"
sudo udevadm settle
