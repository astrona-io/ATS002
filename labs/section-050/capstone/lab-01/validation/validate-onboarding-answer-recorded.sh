#!/usr/bin/env bash
# Confirms /opt/course/onboarding/redis-candidate.txt records
# redis-server's live candidate version and the source repository URL
# that candidate would come from -- both recomputed live here, not
# hardcoded, so a stale or fabricated answer doesn't pass by accident.

set -u

path="/opt/course/onboarding/redis-candidate.txt"

if [[ ! -s "$path" ]]; then
  echo "FAIL: onboarding answer recorded - $path is missing or empty"
  exit 1
fi

expected_candidate=$(apt-cache policy redis-server 2>/dev/null | awk '/Candidate:/{print $2; exit}')

if [[ -z "$expected_candidate" ]]; then
  echo "FAIL: onboarding answer recorded - could not compute a live candidate version for redis-server"
  exit 1
fi

if ! grep -qF -- "$expected_candidate" "$path"; then
  echo "FAIL: onboarding answer recorded - $path does not contain the live candidate version '$expected_candidate'"
  exit 1
fi

expected_source_line=$(apt-cache policy redis-server 2>/dev/null | awk -v ver="$expected_candidate" '$1==ver{getline; gsub(/^[ \t]+/,""); print; exit}')

if [[ -z "$expected_source_line" ]]; then
  echo "FAIL: onboarding answer recorded - could not compute a live source repository line for redis-server"
  exit 1
fi

source_url=$(echo "$expected_source_line" | awk '{print $2}')

if [[ -z "$source_url" ]]; then
  echo "FAIL: onboarding answer recorded - could not parse a source URL from the live apt-cache policy output"
  exit 1
fi

if ! grep -qF -- "$source_url" "$path"; then
  echo "FAIL: onboarding answer recorded - $path does not mention the live source repository '$source_url'"
  exit 1
fi

echo "PASS: $path records redis-server's live candidate version ($expected_candidate) and source ($source_url)"
exit 0
