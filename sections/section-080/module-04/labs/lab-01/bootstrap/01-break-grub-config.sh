#!/usr/bin/env bash
# Breaks lab-084's scenario directly on this VM's own primary disk --
# safely, because only the on-disk GRUB config is touched. This VM's
# CURRENT boot already succeeded before this script ever runs: the
# kernel, initramfs, and GRUB's own installed boot-sector/EFI code that
# got it there are already loaded/in place and are never touched below,
# so SSH stays fully reachable the whole time. Only the NEXT reboot
# would be affected -- if grub.cfg is still gone then, GRUB would come
# up with no valid menu. That's the honest framing this lab uses: "fix
# it before that happens," not "you're already down."
#
# A timestamp marker is recorded before anything is touched so
# validation can later prove the student's repair genuinely happened
# during this session (fresh mtimes on the regenerated grub.cfg and the
# reinstalled boot-sector/EFI image) rather than merely reflecting
# whatever GRUB state already existed in the base VM image.

set -eu

GRUB_CFG=/boot/grub/grub.cfg
MARKER=/root/.lab084-bootstrap-marker

if [ ! -d /boot/grub ]; then
  echo "ERROR: /boot/grub not found -- unexpected image layout" >&2
  exit 1
fi

# Record the marker BEFORE removing anything, so its mtime is a reliable
# "before" timestamp for validation to compare the student's repair
# against.
sudo touch "$MARKER"

# Remove the on-disk GRUB menu configuration -- the exact failure mode
# this lab's source material describes ("a menu... but grub.cfg is
# missing or unreadable"). The currently-running kernel was already
# loaded into memory by the CURRENT boot's GRUB before this file was
# ever touched, so nothing about this VM's live session changes.
sudo rm -f "$GRUB_CFG"

echo "lab-084 bootstrap complete."
echo "  Removed: $GRUB_CFG"
echo "  Marker : $MARKER (repair must postdate this timestamp)"

exit 0
