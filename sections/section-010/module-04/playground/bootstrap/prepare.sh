#!/usr/bin/env bash
# OS prep for the udev playground. A second virtual disk with a fixed
# serial ("BACKUPWD42") is attached via the runtime block; it shows up as
# /dev/vdc. Nothing about udev is configured — that is what you explore.
# No task, no grading.
set -eu

export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -qq
sudo apt-get install -y -qq udev util-linux   # udevadm, lsblk

echo "[playground] udev-stable-naming: ready."
echo "[playground] attached disk:"
lsblk -o NAME,SIZE,SERIAL,TYPE | sed 's/^/[playground]   /'
echo "[playground] try:  udevadm info --attribute-walk --name=/dev/vdc | grep -i serial"
