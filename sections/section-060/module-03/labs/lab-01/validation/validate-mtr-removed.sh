#!/usr/bin/env bash
# Confirms mtr (the package deliberately bundled into the fail2ban install
# to simulate a colleague's mistake) is NOT installed -- proving the
# student actually found the mixed transaction and undid it with
# `dnf history undo`, rather than just manually installing fail2ban and
# ignoring the rest of the scenario.

set -u

if sudo docker exec rpmbox rpm -q mtr >/dev/null 2>&1; then
  echo "FAIL: mtr removed - mtr is still installed inside rpmbox; the mixed transaction was not undone"
  exit 1
fi

echo "PASS: mtr is not installed inside rpmbox"
exit 0
