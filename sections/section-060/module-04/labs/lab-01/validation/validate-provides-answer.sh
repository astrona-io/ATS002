#!/usr/bin/env bash
# Confirms the student recorded the correct dnf provides result for the
# `ip` command at /home/candidate/answers/provides.txt inside rpmbox --
# the answer should point at the iproute package, and iproute should
# still be uninstalled (this lab never installs anything).

set -u

output=$(sudo docker exec rpmbox cat /home/candidate/answers/provides.txt 2>&1)
rc=$?

if [[ $rc -ne 0 ]]; then
  echo "FAIL: provides answer - /home/candidate/answers/provides.txt is missing inside rpmbox ($output)"
  exit 1
fi

if [[ -z "$output" ]]; then
  echo "FAIL: provides answer - /home/candidate/answers/provides.txt is empty inside rpmbox"
  exit 1
fi

if ! grep -qi "iproute" <<< "$output"; then
  echo "FAIL: provides answer - /home/candidate/answers/provides.txt does not mention the iproute package:"
  echo "$output"
  exit 1
fi

if ! grep -q "/ip" <<< "$output"; then
  echo "FAIL: provides answer - /home/candidate/answers/provides.txt does not reference a path ending in /ip:"
  echo "$output"
  exit 1
fi

echo "PASS: provides.txt correctly identifies iproute as providing the ip command"
exit 0
