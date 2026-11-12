#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Inspect protected state; user access checks select their target account explicitly.
sudo -n bash <<'GRADER_ROOT'
# Confirms the /boot/initrd.img link resolves to a file that exists.

set -u

LINK=/boot/initrd.img

if [[ ! -e "$LINK" ]]; then
  echo "FAIL: link - $LINK does not resolve to an existing file"
  exit 1
fi

echo "PASS: $LINK resolves to $(readlink -f "$LINK")"
exit 0
GRADER_ROOT
ASTRONA_STUDENT_SCRIPT
