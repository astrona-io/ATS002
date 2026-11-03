#!/usr/bin/env bash
# Confirms /etc/mdadm/mdadm.conf has an ARRAY line with the array's UUID.

set -u

ARRAY=/dev/md/cargo
CONF=/etc/mdadm/mdadm.conf

if [[ ! -e "$ARRAY" ]]; then
  echo "FAIL: saved - $ARRAY does not exist"
  exit 1
fi

UUID=$(sudo mdadm --detail "$ARRAY" 2>/dev/null | awk '/UUID :/ {print $3; exit}')
if [[ -z "$UUID" ]]; then
  echo "FAIL: saved - could not read the array UUID"
  exit 1
fi

if ! grep -E '^ARRAY' "$CONF" 2>/dev/null | grep -qi "UUID=$UUID"; then
  echo "FAIL: saved - $CONF has no ARRAY line with UUID=$UUID"
  exit 1
fi

echo "PASS: $CONF has an ARRAY line for the array"
exit 0
