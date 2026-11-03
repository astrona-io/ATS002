#!/usr/bin/env bash
# Confirms smart.txt holds the output of smartctl.

set -u

FILE=/var/tmp/disk-report/smart.txt

if [[ ! -s "$FILE" ]]; then
  echo "FAIL: smart - $FILE is missing or empty"
  exit 1
fi

if ! grep -qi 'smartctl' "$FILE"; then
  echo "FAIL: smart - $FILE does not look like smartctl output"
  exit 1
fi

echo "PASS: smart.txt holds smartctl output"
exit 0
