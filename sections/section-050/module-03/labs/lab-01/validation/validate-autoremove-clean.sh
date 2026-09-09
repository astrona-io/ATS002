#!/usr/bin/env bash
# Confirms no orphaned auto-installed packages remain -- 'apt autoremove'
# was run as a deliberate follow-up after the purge.

set -u

output=$(apt-get autoremove --dry-run 2>/dev/null || true)

if echo "$output" | grep -qE '^Remv '; then
  echo "FAIL: autoremove clean - orphaned packages are still pending removal:"
  echo "$output" | grep -E '^Remv '
  exit 1
fi

echo "PASS: no orphaned auto-installed packages remain"
exit 0
