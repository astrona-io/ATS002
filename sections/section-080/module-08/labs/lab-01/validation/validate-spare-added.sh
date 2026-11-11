#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Confirms disk c is an active member of the array and disk b is not.

set -u

ARRAY=/dev/md/cargo
DISK_B_ID=/dev/disk/by-id/virtio-lab089-raid-b
DISK_C_ID=/dev/disk/by-id/virtio-lab089-raid-c

if [[ ! -e "$ARRAY" || ! -e "$DISK_B_ID" || ! -e "$DISK_C_ID" ]]; then
  echo "FAIL: spare - the array or a disk is missing"
  exit 1
fi

DISK_B=$(readlink -f "$DISK_B_ID")
DISK_C=$(readlink -f "$DISK_C_ID")

MEMBERS=$(sudo mdadm --detail "$ARRAY" 2>/dev/null | awk '/active sync/ {print $NF}')

if ! echo "$MEMBERS" | grep -qx "$DISK_C"; then
  echo "FAIL: spare - disk c ($DISK_C) is not an active member"
  exit 1
fi

if echo "$MEMBERS" | grep -qx "$DISK_B"; then
  echo "FAIL: spare - failed disk b ($DISK_B) is an active member again"
  exit 1
fi

echo "PASS: disk c is an active member and disk b is not"
exit 0
ASTRONA_STUDENT_SCRIPT
