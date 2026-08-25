#!/usr/bin/env bash
# Breaks this capstone's "stale GRUB config" half directly on this VM's
# own primary disk -- safely, using the exact lab-084 mechanism. This
# VM's CURRENT boot already succeeded before this script ever runs: the
# kernel, initramfs, and GRUB's own installed boot-sector/EFI code that
# got it there are already loaded/in place and are never touched below,
# so SSH stays fully reachable the whole time. Only the NEXT reboot
# would be affected -- exactly the "fix it before that happens" framing
# this capstone shares with lab-084.
#
# A timestamp marker is recorded before anything is touched so
# validation can later prove the student's repair genuinely happened
# during this session.

set -eu

GRUB_CFG=/boot/grub/grub.cfg
MARKER=/root/.lab080-bootstrap-marker

if [ ! -d /boot/grub ]; then
  echo "ERROR: /boot/grub not found -- unexpected image layout" >&2
  exit 1
fi

sudo touch "$MARKER"

sudo rm -f "$GRUB_CFG"

echo "lab-080 bootstrap (primary disk) complete."
echo "  Removed: $GRUB_CFG"
echo "  Marker : $MARKER (repair must postdate this timestamp)"

exit 0
