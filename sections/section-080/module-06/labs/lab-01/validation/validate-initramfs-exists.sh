#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Confirms the initramfs image of the running kernel exists again and was
# created after the lab started.

set -u

INITRD="/boot/initrd.img-$(uname -r)"

if ! sudo test -s "$INITRD"; then
  echo "FAIL: initramfs - $INITRD is missing or empty"
  exit 1
fi

START=$(sudo cat /root/.lab087-start 2>/dev/null || echo 0)
MTIME=$(stat -c %Y "$INITRD")

if (( MTIME < START )); then
  echo "FAIL: initramfs - $INITRD is older than the start of the lab"
  exit 1
fi

echo "PASS: $INITRD exists and was rebuilt during the lab"
exit 0
ASTRONA_STUDENT_SCRIPT
