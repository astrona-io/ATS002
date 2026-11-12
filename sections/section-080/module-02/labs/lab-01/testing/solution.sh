#!/usr/bin/env bash
set -euo pipefail
sudo mkdir -p /mnt/repair
sudo mount /dev/disk/by-id/virtio-lab082-data001 /mnt/repair
hash=$(openssl passwd -6 'NewSecurePass123!')
sudo sed -i "s|^root:[^:]*:|root:$hash:|" /mnt/repair/etc/shadow
sudo umount /mnt/repair
