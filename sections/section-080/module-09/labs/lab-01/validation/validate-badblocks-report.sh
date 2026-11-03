#!/usr/bin/env bash
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
