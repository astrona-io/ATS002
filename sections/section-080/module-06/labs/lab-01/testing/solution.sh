#!/usr/bin/env bash
set -euo pipefail
sudo update-initramfs -c -k "$(uname -r)"
sudo ln -sf "initrd.img-$(uname -r)" /boot/initrd.img
