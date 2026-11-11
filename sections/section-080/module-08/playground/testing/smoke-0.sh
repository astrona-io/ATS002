#!/usr/bin/env bash
set -euo pipefail
for tool in lsblk blkid mount; do command -v "$tool"; done
sudo test -b /dev/disk/by-id/virtio-lab089-raid-a
sudo test -b /dev/disk/by-id/virtio-lab089-raid-b
sudo test -b /dev/disk/by-id/virtio-lab089-raid-c
