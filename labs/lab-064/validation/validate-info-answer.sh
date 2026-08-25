#!/usr/bin/env bash
# Confirms the student recorded httpd's full dnf metadata at
# /home/candidate/answers/info.txt inside rpmbox, and that httpd itself
# was never actually installed -- this lab is entirely read-only, and
# `dnf info` should never have touched installed-package state.

set -u

output=$(sudo docker exec rpmbox cat /home/candidate/answers/info.txt 2>&1)
rc=$?

if [[ $rc -ne 0 ]]; then
  echo "FAIL: info answer - /home/candidate/answers/info.txt is missing inside rpmbox ($output)"
  exit 1
fi

if ! grep -qE "^Name[[:space:]]*:[[:space:]]*httpd" <<< "$output"; then
  echo "FAIL: info answer - /home/candidate/answers/info.txt does not contain a 'Name : httpd' line:"
  echo "$output"
  exit 1
fi

if ! grep -qE "^Version[[:space:]]*:" <<< "$output"; then
  echo "FAIL: info answer - /home/candidate/answers/info.txt does not contain a Version field:"
  echo "$output"
  exit 1
fi

if sudo docker exec rpmbox rpm -q httpd >/dev/null 2>&1; then
  echo "FAIL: info answer - httpd is actually installed inside rpmbox; this lab is read-only, dnf info should not have caused an install"
  exit 1
fi

echo "PASS: info.txt records httpd's metadata, and httpd was never installed"
exit 0
