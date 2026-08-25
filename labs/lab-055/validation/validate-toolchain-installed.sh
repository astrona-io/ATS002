#!/usr/bin/env bash
# Confirms build-essential, git, cmake, and pkg-config are all cleanly
# installed (installed via a single apt install transaction per the
# task, but this only verifies the resulting state, not the exact
# command used).

set -u

fail=0

for pkg in build-essential git cmake pkg-config; do
  status=$(dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null || echo "")
  if [[ "$status" != "install ok installed" ]]; then
    echo "FAIL: toolchain installed - '$pkg' status is '$status', expected 'install ok installed'"
    fail=1
  fi
done

if [[ "$fail" -ne 0 ]]; then
  exit 1
fi

echo "PASS: build-essential, git, cmake, and pkg-config are all installed"
exit 0
