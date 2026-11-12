#!/usr/bin/env bash
set -euo pipefail
disk=$(readlink -f /dev/disk/by-id/virtio-lab086-data001)
set +e
sudo e2fsck -b 32768 -y "${disk}1"
rc=$?
set -e
test "$rc" -le 1
printf '%s
' 32768 | sudo tee /root/backup-superblock.txt
