#!/usr/bin/env bash
# Confirms /opt/course/apt-research/python3-installed.txt matches the
# live set of installed python3-* packages, compared as a sorted set so
# line order doesn't matter.

set -u

path="/opt/course/apt-research/python3-installed.txt"

if [[ ! -s "$path" ]]; then
  echo "FAIL: python3 list recorded - $path is missing or empty"
  exit 1
fi

expected=$(apt list --installed 2>/dev/null | grep '^python3-' | cut -d/ -f1 | sort -u)
recorded=$(grep '^python3-' "$path" | cut -d/ -f1 | sort -u)

if [[ -z "$expected" ]]; then
  echo "FAIL: python3 list recorded - could not compute a live python3-* package list to compare against"
  exit 1
fi

if [[ "$recorded" != "$expected" ]]; then
  echo "FAIL: python3 list recorded - recorded package set does not match the live installed python3-* set"
  echo "--- expected ---"
  echo "$expected"
  echo "--- recorded ---"
  echo "$recorded"
  exit 1
fi

echo "PASS: $path matches the live set of installed python3-* packages"
exit 0
