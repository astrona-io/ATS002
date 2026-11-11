#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# OS prep for PLAYGROUND: GRUB Recovery
#
# Runs once when the environment comes up. The machine stays healthy: this
# only saves a copy of the current GRUB menu file so you can compare any
# file you generate with it. It never removes or changes /boot/grub/grub.cfg.
set -eu

if [ -f /boot/grub/grub.cfg ]; then
  sudo cp -p /boot/grub/grub.cfg /root/grub.cfg.original
  echo "[playground] grub-repair-bench: saved /root/grub.cfg.original"
else
  echo "[playground] grub-repair-bench: no /boot/grub/grub.cfg found on this image"
fi
ASTRONA_STUDENT_SCRIPT
