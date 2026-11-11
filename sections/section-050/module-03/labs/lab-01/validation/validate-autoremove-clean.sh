#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
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
ASTRONA_STUDENT_SCRIPT
