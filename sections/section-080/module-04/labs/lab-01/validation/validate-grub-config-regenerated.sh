#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
set -u

GRUB_CFG=/boot/grub/grub.cfg
MARKER=/root/.lab084-bootstrap-marker

if ! sudo test -e "$MARKER"; then
  echo "FAIL: grub config regenerated - bootstrap marker $MARKER not found (did bootstrap run?)"
  exit 1
fi

if ! sudo test -f "$GRUB_CFG"; then
  echo "FAIL: grub config regenerated - $GRUB_CFG does not exist"
  exit 1
fi

SIZE=$(sudo stat -c%s "$GRUB_CFG" 2>/dev/null || echo 0)
if [[ "$SIZE" -le 0 ]]; then
  echo "FAIL: grub config regenerated - $GRUB_CFG is empty"
  exit 1
fi

MENUENTRIES=$(sudo grep -c '^menuentry' "$GRUB_CFG" 2>/dev/null || echo 0)
if [[ "$MENUENTRIES" -lt 1 ]]; then
  echo "FAIL: grub config regenerated - $GRUB_CFG contains no menuentry lines"
  exit 1
fi

MARKER_TS=$(sudo stat -c %Y "$MARKER" 2>/dev/null || echo 0)
CFG_TS=$(sudo stat -c %Y "$GRUB_CFG" 2>/dev/null || echo 0)

if [[ "$CFG_TS" -le "$MARKER_TS" ]]; then
  echo "FAIL: grub config regenerated - $GRUB_CFG is not newer than the bootstrap marker; it does not appear to have been regenerated this session"
  exit 1
fi

echo "PASS: $GRUB_CFG exists, is non-empty, contains $MENUENTRIES menuentry line(s), and was regenerated after bootstrap"
exit 0
ASTRONA_STUDENT_SCRIPT
