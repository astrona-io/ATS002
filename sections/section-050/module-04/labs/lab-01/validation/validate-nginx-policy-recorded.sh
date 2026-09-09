#!/usr/bin/env bash
# Confirms /opt/course/apt-research/nginx-policy.txt contains
# Installed:/Candidate: lines matching 'apt-cache policy nginx's live
# output, computed fresh here rather than hardcoded.

set -u

path="/opt/course/apt-research/nginx-policy.txt"

if [[ ! -s "$path" ]]; then
  echo "FAIL: nginx policy recorded - $path is missing or empty"
  exit 1
fi

expected_installed=$(apt-cache policy nginx 2>/dev/null | awk '/Installed:/{print $2; exit}')
expected_candidate=$(apt-cache policy nginx 2>/dev/null | awk '/Candidate:/{print $2; exit}')

recorded_installed=$(grep -m1 -E 'Installed:' "$path" | awk '{print $2}')
recorded_candidate=$(grep -m1 -E 'Candidate:' "$path" | awk '{print $2}')

if [[ -z "$recorded_installed" || "$recorded_installed" != "$expected_installed" ]]; then
  echo "FAIL: nginx policy recorded - recorded Installed: '$recorded_installed', expected '$expected_installed'"
  exit 1
fi

if [[ -z "$recorded_candidate" || "$recorded_candidate" != "$expected_candidate" ]]; then
  echo "FAIL: nginx policy recorded - recorded Candidate: '$recorded_candidate', expected '$expected_candidate'"
  exit 1
fi

echo "PASS: $path matches live apt-cache policy output (Installed: $recorded_installed, Candidate: $recorded_candidate)"
exit 0
