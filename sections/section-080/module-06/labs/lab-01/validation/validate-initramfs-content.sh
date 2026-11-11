#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Inspect protected state; user access checks select their target account explicitly.
sudo -n bash <<'GRADER_ROOT'
# Confirms the rebuilt image is a real, readable initramfs.

set -u

INITRD="/boot/initrd.img-$(uname -r)"

if ! sudo test -s "$INITRD"; then
  echo "FAIL: content - $INITRD is missing or empty"
  exit 1
fi

if ! LIST=$(sudo lsinitramfs "$INITRD" 2>/dev/null); then
  echo "FAIL: content - lsinitramfs cannot read $INITRD"
  exit 1
fi

if ! grep -q "scripts/init-top" <<<"$LIST"; then
  echo "FAIL: content - $INITRD does not contain the initramfs boot scripts"
  exit 1
fi

echo "PASS: $INITRD is a readable initramfs with the boot scripts inside"
exit 0
GRADER_ROOT
ASTRONA_STUDENT_SCRIPT
