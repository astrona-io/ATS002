#!/usr/bin/env bash
# Confirms rpm -qa inside rpmbox completes cleanly (no database errors) and
# returns a plausible, non-trivial package count -- proving the database
# was genuinely repaired, not just partially patched.

set -u

output=$(sudo docker exec rpmbox rpm -qa 2>&1)
rc=$?

if [[ $rc -ne 0 ]]; then
  echo "FAIL: rpmdb queryable - rpm -qa exited non-zero inside rpmbox:"
  echo "$output"
  exit 1
fi

if grep -qi "error" <<< "$output"; then
  echo "FAIL: rpmdb queryable - rpm -qa output still contains error text:"
  echo "$output" | grep -i "error"
  exit 1
fi

count=$(wc -l <<< "$output")
if [[ "$count" -lt 20 ]]; then
  echo "FAIL: rpmdb queryable - rpm -qa only returned $count packages, expected a plausible non-trivial count"
  exit 1
fi

echo "PASS: rpm -qa is clean and returned $count packages"
exit 0
