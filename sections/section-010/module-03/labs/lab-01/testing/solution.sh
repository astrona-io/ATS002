#!/usr/bin/env bash
set -euo pipefail
sudo mkdir -p /etc/modules-load.d
sudo tee /etc/modules-load.d/dummy.conf >/dev/null <<'REFERENCE_FILE'
dummy
REFERENCE_FILE
sudo mkdir -p /etc/modprobe.d
sudo tee /etc/modprobe.d/zz-course-dummy.conf >/dev/null <<'REFERENCE_FILE'
options dummy numdummies=2
REFERENCE_FILE
sudo mkdir -p /etc/modprobe.d
sudo tee /etc/modprobe.d/blacklist-pcspkr.conf >/dev/null <<'REFERENCE_FILE'
blacklist pcspkr
REFERENCE_FILE
if test -d /sys/module/dummy; then sudo modprobe -r dummy; fi
sudo modprobe dummy
if test -d /sys/module/pcspkr; then sudo modprobe -r pcspkr; fi
