#!/usr/bin/env bash
# Confirms the /boot/initrd.img link resolves to a file that exists.

set -u

LINK=/boot/initrd.img

if [[ ! -e "$LINK" ]]; then
  echo "FAIL: link - $LINK does not resolve to an existing file"
  exit 1
fi

echo "PASS: $LINK resolves to $(readlink -f "$LINK")"
exit 0
