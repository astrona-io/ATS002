#!/usr/bin/env bash
set -euo pipefail
disk=$(readlink -f /dev/disk/by-id/virtio-lab088-pv001)
uuid=$(sudo awk '/pv0 \{/ {found=1} found && /id =/ {gsub(/"/,"",$3); print $3; exit}' /etc/lvm/backup/cargo_vg)
test -n "$uuid"
sudo pvcreate --uuid "$uuid" --restorefile /etc/lvm/backup/cargo_vg "$disk"
sudo vgcfgrestore cargo_vg
sudo vgchange -ay cargo_vg
sudo mkdir -p /srv/deck
sudo mount /dev/cargo_vg/deck /srv/deck
