#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Inspect protected state; user access checks select their target account explicitly.
sudo -n bash <<'GRADER_ROOT'
# Confirms kernel-errors.txt holds the I/O error line about the suspect disk.

set -u

FILE=/var/tmp/disk-report/kernel-errors.txt
SUSPECT_ID=/dev/disk/by-id/virtio-lab08a-suspect

if [[ ! -e "$SUSPECT_ID" ]]; then
  echo "FAIL: kernel - the suspect disk is missing"
  exit 1
fi

NAME=$(basename "$(readlink -f "$SUSPECT_ID")")

if [[ ! -s "$FILE" ]]; then
  echo "FAIL: kernel - $FILE is missing or empty"
  exit 1
fi

if ! grep -i 'i/o error' "$FILE" | grep -q "dev $NAME"; then
  echo "FAIL: kernel - $FILE has no I/O error line for dev $NAME"
  exit 1
fi

echo "PASS: kernel-errors.txt has the I/O error for $NAME"
exit 0
GRADER_ROOT
ASTRONA_STUDENT_SCRIPT
