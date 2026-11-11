#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Confirms /dev/md/cargo is clean with two active devices and none failed.

set -u

ARRAY=/dev/md/cargo

if [[ ! -e "$ARRAY" ]]; then
  echo "FAIL: healthy - $ARRAY does not exist"
  exit 1
fi

DETAIL=$(sudo mdadm --detail "$ARRAY" 2>/dev/null)
STATE=$(echo "$DETAIL" | awk -F' : ' '/^ *State :/ {print $2; exit}')
ACTIVE=$(echo "$DETAIL" | awk -F' : ' '/Active Devices :/ {gsub(/ /, "", $2); print $2; exit}')
FAILED=$(echo "$DETAIL" | awk -F' : ' '/Failed Devices :/ {gsub(/ /, "", $2); print $2; exit}')

if [[ "$STATE" != "clean" && "$STATE" != "active" ]]; then
  echo "FAIL: healthy - array state is '$STATE', expected clean"
  exit 1
fi

if [[ "$ACTIVE" != "2" ]]; then
  echo "FAIL: healthy - $ACTIVE active devices, expected 2"
  exit 1
fi

if [[ "$FAILED" != "0" ]]; then
  echo "FAIL: healthy - $FAILED failed devices, expected 0"
  exit 1
fi

echo "PASS: $ARRAY is clean with two active devices"
exit 0
ASTRONA_STUDENT_SCRIPT
