#!/usr/bin/env bash
set -euo pipefail
suspect=$(readlink -f /dev/disk/by-id/virtio-lab08a-suspect)
printf '%s
' "$suspect" | sudo tee /var/tmp/disk-report/device.txt
lsblk -bdno SIZE "$suspect" | sudo tee /var/tmp/disk-report/size.txt
set +e
sudo smartctl -H "$suspect" > /tmp/smart.out 2>&1
rc=$?
set -e
test "$rc" -lt 126
sudo cp /tmp/smart.out /var/tmp/disk-report/smart.txt
sudo dmesg | grep -i 'i/o error' | sudo tee /var/tmp/disk-report/kernel-errors.txt
sudo badblocks -sv "$suspect" 2>&1 | sudo tee /var/tmp/disk-report/badblocks.txt
