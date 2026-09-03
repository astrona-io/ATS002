#!/usr/bin/env bash
# Confirms curl, git, and jq are all cleanly installed.

set -u

fail=0

for pkg in curl git jq; do
  status=$(dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null || echo "")
  if [[ "$status" != "install ok installed" ]]; then
    echo "FAIL: toolchain installed - '$pkg' status is '$status', expected 'install ok installed'"
    fail=1
  fi
done

if [[ "$fail" -ne 0 ]]; then
  exit 1
fi

echo "PASS: curl, git, and jq are all installed"
exit 0
