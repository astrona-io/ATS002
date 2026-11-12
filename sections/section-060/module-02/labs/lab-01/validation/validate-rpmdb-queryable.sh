#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Inspect protected state; user access checks select their target account explicitly.
sudo -n bash <<'GRADER_ROOT'
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

if grep -qi "^error:" <<< "$output"; then
  echo "FAIL: rpmdb queryable - rpm -qa output still contains error text:"
  echo "$output" | grep -i "error"
  exit 1
fi

count=$(wc -l <<< "$output")
if [[ "$count" -lt 20 ]]; then
  echo "FAIL: rpmdb queryable - rpm -qa only returned $count packages, expected a plausible non-trivial count"
  exit 1
fi

if ! sudo docker exec -i rpmbox bash <<'INVENTORY_CHECK'
  set -euo pipefail
  current=$(mktemp)
  trap 'rm -f "$current"' EXIT
  rpm -qa | LC_ALL=C sort > "$current"
  missing=$(LC_ALL=C comm -23 /root/rpm-packages-before.txt "$current")
  test -z "$missing" || { printf "Missing records:\n%s\n" "$missing"; exit 1; }
INVENTORY_CHECK
then
  echo "FAIL: rpmdb inventory is missing original package records"
  exit 1
fi

echo "PASS: rpm -qa is clean and returned $count packages"
exit 0
GRADER_ROOT
ASTRONA_STUDENT_SCRIPT
