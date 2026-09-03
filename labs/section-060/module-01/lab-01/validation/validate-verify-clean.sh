#!/usr/bin/env bash
# Confirms `rpm -V logship-agent` reports a clean verify (no output) inside
# rpmbox -- proving the installed files still match what rpm recorded at
# install time.

set -u

output=$(sudo docker exec rpmbox rpm -V logship-agent 2>&1)
rc=$?

if [[ $rc -ne 0 ]]; then
  echo "FAIL: verify clean - rpm -V logship-agent reported drift or an error:"
  echo "$output"
  exit 1
fi

if [[ -n "$output" ]]; then
  echo "FAIL: verify clean - rpm -V logship-agent printed unexpected output:"
  echo "$output"
  exit 1
fi

echo "PASS: rpm -V logship-agent is clean"
exit 0
