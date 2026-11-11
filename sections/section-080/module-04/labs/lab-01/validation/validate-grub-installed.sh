#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
set -u

MARKER=/root/.lab084-bootstrap-marker

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

if ! sudo grub-script-check /boot/grub/grub.cfg; then
  echo 'FAIL: generated GRUB configuration has syntax errors'
  exit 1
fi
echo "PASS: $CORE_IMG was rewritten after bootstrap; generated GRUB syntax is valid"
exit 0
ASTRONA_STUDENT_SCRIPT
