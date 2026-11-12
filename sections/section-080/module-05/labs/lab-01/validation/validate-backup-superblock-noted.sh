#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Inspect protected state; user access checks select their target account explicitly.
sudo -n bash <<'GRADER_ROOT'
# Confirms the student recorded which backup superblock they used.
# With 4096-byte blocks on a filesystem this size the backups are at
# 32768, 98304, 163840 and 229376.

set -u

FILE=/root/backup-superblock.txt

if ! sudo test -s "$FILE"; then
  echo "FAIL: note - $FILE is missing or empty"
  exit 1
fi

VALUE=$(sudo tr -d '[:space:]' < "$FILE")

case "$VALUE" in
  32768|98304|163840|229376)
    echo "PASS: $FILE names backup superblock $VALUE"
    exit 0
    ;;
  *)
    echo "FAIL: note - '$VALUE' is not a backup superblock number for this filesystem"
    exit 1
    ;;
esac
GRADER_ROOT
ASTRONA_STUDENT_SCRIPT
