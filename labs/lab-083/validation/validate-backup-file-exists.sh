#!/usr/bin/env bash
# Confirms a non-empty sgdisk partition-table backup file was created at
# the path the lab instructs (/root/vdc-ptable-backup.bin), proving the
# student actually took a backup before touching anything, per the
# "backup before risky work" discipline this lab teaches.

set -u

BACKUP=/root/vdc-ptable-backup.bin

if ! sudo test -e "$BACKUP"; then
  echo "FAIL: backup file exists - $BACKUP does not exist"
  exit 1
fi

SIZE=$(sudo stat -c%s "$BACKUP" 2>/dev/null || echo 0)
if [[ "$SIZE" -le 0 ]]; then
  echo "FAIL: backup file exists - $BACKUP is empty"
  exit 1
fi

echo "PASS: $BACKUP exists and is non-empty ($SIZE bytes)"
exit 0
