#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Inspect protected state; user access checks select their target account explicitly.
sudo -n bash <<'GRADER_ROOT'
# Confirms badblocks.txt holds the summary of a finished scan.

set -u

FILE=/var/tmp/disk-report/badblocks.txt

if [[ ! -s "$FILE" ]]; then
  echo "FAIL: badblocks - $FILE is missing or empty"
  exit 1
fi

if ! grep -Eq 'Pass completed, [0-9]+ bad blocks found' "$FILE"; then
  echo "FAIL: badblocks - $FILE has no scan summary (use badblocks -sv)"
  exit 1
fi

echo "PASS: badblocks.txt holds a finished scan summary"
exit 0
GRADER_ROOT
ASTRONA_STUDENT_SCRIPT
