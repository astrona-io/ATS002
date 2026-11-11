#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Inspect protected state; user access checks select their target account explicitly.
sudo -n bash <<'GRADER_ROOT'
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

history=$(sudo docker exec -i rpmbox bash -s <<'HISTORY_SCRIPT'
ids=$(dnf history list | awk -F '|' '$1 ~ /^[[:space:]]*[0-9]+[[:space:]]*$/ {gsub(/ /,"",$1); print $1}')
dnf history info $ids
HISTORY_SCRIPT
)

if ! grep -Eqi 'group install.*Development Tools' <<< "$history" || ! grep -Eqi 'group remove.*Development Tools' <<< "$history"; then
  echo "FAIL: group not installed - transaction history does not show the required install/remove cycle"
  exit 1
fi

echo "PASS: Development Tools group no longer shows as installed inside rpmbox"
exit 0
GRADER_ROOT
ASTRONA_STUDENT_SCRIPT
