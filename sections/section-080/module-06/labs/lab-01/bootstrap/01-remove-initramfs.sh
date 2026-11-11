#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Builds the STARTING state for lab-087: the initramfs image of the running
# kernel is deleted from /boot. The machine keeps running (the kernel is
# already in memory), so it stays reachable over SSH. Nothing reboots it.

set -eu

KVER=$(uname -r)
INITRD="/boot/initrd.img-${KVER}"

if [ ! -f "$INITRD" ]; then
  echo "expected $INITRD to exist before the lab breaks it" >&2
  exit 1
fi

# Remember when the lab started, so the grader can tell a rebuilt image
# from an old one.
date +%s | sudo tee /root/.lab087-start >/dev/null

sudo rm -f "$INITRD"
sync
ASTRONA_STUDENT_SCRIPT
