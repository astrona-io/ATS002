#!/usr/bin/env bash
set -euo pipefail
sudo mdadm /dev/md/cargo --add /dev/disk/by-id/virtio-lab089-raid-c
sudo mdadm --wait /dev/md/cargo
sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf
sudo update-initramfs -u
