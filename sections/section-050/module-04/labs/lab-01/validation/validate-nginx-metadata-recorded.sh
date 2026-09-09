#!/usr/bin/env bash
# Confirms /opt/course/apt-research/nginx-show.txt contains nginx's
# Package/Version fields from 'apt show nginx', with the recorded
# Version matching the live candidate version (computed fresh here, not
# hardcoded), so a stale or fabricated file doesn't pass by accident.

set -u

path="/opt/course/apt-research/nginx-show.txt"

if [[ ! -s "$path" ]]; then
  echo "FAIL: nginx metadata recorded - $path is missing or empty"
  exit 1
fi

if ! grep -qE '^Package:[[:space:]]*nginx$' "$path"; then
  echo "FAIL: nginx metadata recorded - $path does not contain a 'Package: nginx' line"
  exit 1
fi

recorded_version=$(grep -m1 -E '^Version:' "$path" | awk '{print $2}')
expected_version=$(apt-cache policy nginx 2>/dev/null | awk '/Candidate:/{print $2; exit}')

if [[ -z "$recorded_version" ]]; then
  echo "FAIL: nginx metadata recorded - $path does not contain a 'Version:' line"
  exit 1
fi

if [[ -z "$expected_version" || "$recorded_version" != "$expected_version" ]]; then
  echo "FAIL: nginx metadata recorded - recorded Version '$recorded_version' does not match live candidate version '$expected_version'"
  exit 1
fi

echo "PASS: $path contains nginx's Package/Version metadata matching the live candidate version ($recorded_version)"
exit 0
