#!/usr/bin/env bash
# Confirms dnf's own transaction-check logic (dnf check) passes cleanly
# inside rpmbox after the full incident: database rebuild, the standalone
# RPM install, and the Development Tools group install.

set -u

output=$(sudo docker exec rpmbox dnf check 2>&1)
rc=$?

if [[ $rc -ne 0 ]]; then
  echo "FAIL: dnf check clean - dnf check exited non-zero inside rpmbox:"
  echo "$output"
  exit 1
fi

echo "PASS: dnf check passed cleanly inside rpmbox"
exit 0
