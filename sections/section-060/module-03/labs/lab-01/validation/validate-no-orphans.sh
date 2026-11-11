#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Inspect protected state; user access checks select their target account explicitly.
sudo -n bash <<'GRADER_ROOT'
# Confirms no orphaned dependency packages remain pending removal inside
# rpmbox after the telnet cleanup.

set -u

output=$(sudo docker exec rpmbox dnf autoremove --assumeno 2>&1)

if grep -qiE "Remove +[0-9]+ Package" <<< "$output"; then
  echo "FAIL: no orphans - dnf autoremove still has packages pending removal inside rpmbox:"
  echo "$output"
  exit 1
fi

echo "PASS: no orphaned packages remain inside rpmbox"
exit 0
GRADER_ROOT
ASTRONA_STUDENT_SCRIPT
