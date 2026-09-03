#!/usr/bin/env bash
# Confirms GRUB's own installed boot-sector/EFI code on the primary disk
# was genuinely reinstalled during this session -- not just left over
# from the base VM image -- and that a final `grub-install --recheck`
# confirms it is healthy. Runs entirely over the still-live SSH session;
# no reboot required or attempted.
#
# Freshness (the installed core.img/core.efi file's mtime versus the
# bootstrap marker recorded before the student ever touched anything) is
# the real discriminator here: bootstrap never actually corrupted the
# boot-sector/EFI code itself, only grub.cfg, so `grub-install --recheck`
# would report success on this VM regardless of whether the student ever
# ran grub-install. "The recheck succeeds" alone proves nothing; "the
# installed image was rewritten after the marker" proves the student
# genuinely ran grub-install this session.

set -u

MARKER=/root/.lab080-bootstrap-marker

if ! sudo test -e "$MARKER"; then
  echo "FAIL: grub installed - bootstrap marker $MARKER not found (did bootstrap run?)"
  exit 1
fi
MARKER_TS=$(sudo stat -c %Y "$MARKER" 2>/dev/null || echo 0)

CORE_IMG=$(sudo find /boot/grub -maxdepth 2 -type f -name 'core.*' 2>/dev/null | head -n1)
if [[ -z "$CORE_IMG" ]]; then
  echo "FAIL: grub installed - no installed core.img/core.efi found under /boot/grub"
  exit 1
fi

CORE_SIZE=$(sudo stat -c%s "$CORE_IMG" 2>/dev/null || echo 0)
if [[ "$CORE_SIZE" -le 0 ]]; then
  echo "FAIL: grub installed - $CORE_IMG is empty"
  exit 1
fi

CORE_TS=$(sudo stat -c %Y "$CORE_IMG" 2>/dev/null || echo 0)
if [[ "$CORE_TS" -le "$MARKER_TS" ]]; then
  echo "FAIL: grub installed - $CORE_IMG was not rewritten after the bootstrap marker; grub-install does not appear to have actually run this session"
  exit 1
fi

# Final confirmation, exactly as the student's own last self-check step:
# resolve the primary disk and firmware mode, then ask grub-install to
# recheck itself.
ROOT_SRC=$(findmnt -no SOURCE / 2>/dev/null || true)
if [[ -z "$ROOT_SRC" ]]; then
  echo "FAIL: grub installed - could not determine the root filesystem's source device"
  exit 1
fi

PKNAME=$(lsblk -no PKNAME "$ROOT_SRC" 2>/dev/null || true)
if [[ -z "$PKNAME" ]]; then
  echo "FAIL: grub installed - could not resolve the parent disk of $ROOT_SRC"
  exit 1
fi
DISK="/dev/$PKNAME"

RECHECK_LOG=$(mktemp)
if [[ -d /sys/firmware/efi ]]; then
  if ! sudo grub-install --recheck --target=x86_64-efi --efi-directory=/boot/efi >"$RECHECK_LOG" 2>&1; then
    echo "FAIL: grub installed - grub-install --recheck (UEFI) reported an error:"
    cat "$RECHECK_LOG"
    rm -f "$RECHECK_LOG"
    exit 1
  fi
else
  if ! sudo grub-install --recheck "$DISK" >"$RECHECK_LOG" 2>&1; then
    echo "FAIL: grub installed - grub-install --recheck reported an error on $DISK:"
    cat "$RECHECK_LOG"
    rm -f "$RECHECK_LOG"
    exit 1
  fi
fi
rm -f "$RECHECK_LOG"

echo "PASS: $CORE_IMG was genuinely rewritten after bootstrap ($CORE_SIZE bytes) and grub-install --recheck on $DISK confirms GRUB is healthy"
exit 0
