#!/usr/bin/env bash
# Confirms the "Development Tools" group no longer shows as installed
# inside rpmbox -- proving the group was actually removed as a unit, not
# just left in place.

set -u

output=$(sudo docker exec rpmbox dnf group list installed 2>&1)
rc=$?

if [[ $rc -ne 0 ]]; then
  echo "FAIL: group not installed - dnf group list installed failed inside rpmbox:"
  echo "$output"
  exit 1
fi

if grep -qi "Development Tools" <<< "$output"; then
  echo "FAIL: group not installed - Development Tools still shows as installed inside rpmbox:"
  echo "$output"
  exit 1
fi

echo "PASS: Development Tools group no longer shows as installed inside rpmbox"
exit 0
