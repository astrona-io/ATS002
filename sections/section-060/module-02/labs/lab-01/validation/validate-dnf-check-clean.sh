#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Inspect protected state; user access checks select their target account explicitly.
sudo -n bash <<'GRADER_ROOT'
# Confirms dnf's own transaction-check logic (dnf check) passes cleanly
# against the rebuilt database inside rpmbox -- this is the thing that was
# actually failing in the original corrupted-database symptom, not just
# rpm -qa.

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
GRADER_ROOT
ASTRONA_STUDENT_SCRIPT
