#!/usr/bin/env bash
# Confirms the student recorded the installed python3-* package listing at
# /home/candidate/answers/python-packages.txt inside rpmbox, including the
# extra python3-* packages bootstrap installed.

set -u

output=$(sudo docker exec rpmbox cat /home/candidate/answers/python-packages.txt 2>&1)
rc=$?

if [[ $rc -ne 0 ]]; then
  echo "FAIL: python answer - /home/candidate/answers/python-packages.txt is missing inside rpmbox ($output)"
  exit 1
fi

if [[ -z "$output" ]]; then
  echo "FAIL: python answer - /home/candidate/answers/python-packages.txt is empty inside rpmbox"
  exit 1
fi

if ! grep -q "^python3-" <<< "$output"; then
  echo "FAIL: python answer - /home/candidate/answers/python-packages.txt has no line starting with python3-:"
  echo "$output"
  exit 1
fi

for pkg in python3-pip python3-setuptools python3-requests; do
  if ! grep -q "^${pkg}\." <<< "$output"; then
    echo "FAIL: python answer - /home/candidate/answers/python-packages.txt is missing expected package ${pkg}:"
    echo "$output"
    exit 1
  fi
done

echo "PASS: python-packages.txt lists the expected installed python3-* packages"
exit 0
