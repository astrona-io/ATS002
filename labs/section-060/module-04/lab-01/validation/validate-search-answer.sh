#!/usr/bin/env bash
# Confirms the student recorded a fail2ban-related `dnf search` result at
# /home/candidate/answers/search.txt inside rpmbox.

set -u

output=$(sudo docker exec rpmbox cat /home/candidate/answers/search.txt 2>&1)
rc=$?

if [[ $rc -ne 0 ]]; then
  echo "FAIL: search answer - /home/candidate/answers/search.txt is missing inside rpmbox ($output)"
  exit 1
fi

if [[ -z "$output" ]]; then
  echo "FAIL: search answer - /home/candidate/answers/search.txt is empty inside rpmbox"
  exit 1
fi

if ! grep -qi "fail2ban" <<< "$output"; then
  echo "FAIL: search answer - /home/candidate/answers/search.txt does not mention fail2ban:"
  echo "$output"
  exit 1
fi

echo "PASS: search.txt records a fail2ban-related dnf search result"
exit 0
