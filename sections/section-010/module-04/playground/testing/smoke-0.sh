#!/usr/bin/env bash
set -euo pipefail
for tool in sysctl modprobe systemctl; do command -v "$tool"; done
sudo test -b /dev/disk/by-id/virtio-BACKUPWD42
