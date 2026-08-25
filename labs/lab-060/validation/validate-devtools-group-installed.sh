#!/usr/bin/env bash
# Confirms the "Development Tools" group shows as installed inside rpmbox,
# with real core build tools (gcc, make) actually present -- proving the
# group install landed real packages, not just a metadata label.

set -u

group_output=$(sudo docker exec rpmbox dnf group list installed 2>&1)
rc=$?

if [[ $rc -ne 0 ]]; then
  echo "FAIL: devtools group installed - dnf group list installed failed inside rpmbox:"
  echo "$group_output"
  exit 1
fi

if ! grep -qi "Development Tools" <<< "$group_output"; then
  echo "FAIL: devtools group installed - Development Tools does not show as installed inside rpmbox:"
  echo "$group_output"
  exit 1
fi

if ! sudo docker exec rpmbox rpm -q gcc >/dev/null 2>&1; then
  echo "FAIL: devtools group installed - gcc is not installed inside rpmbox"
  exit 1
fi

if ! sudo docker exec rpmbox rpm -q make >/dev/null 2>&1; then
  echo "FAIL: devtools group installed - make is not installed inside rpmbox"
  exit 1
fi

echo "PASS: Development Tools group is installed inside rpmbox with gcc and make present"
exit 0
