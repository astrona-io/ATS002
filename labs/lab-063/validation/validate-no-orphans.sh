#!/usr/bin/env bash
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
