#!/usr/bin/env bash
# Confirms /opt/course/apt-research/upgradable.txt matches the live
# 'apt list --upgradable' output, compared by package name as a sorted
# set (versions in the live environment can shift between bootstrap and
# grading, so this compares which packages are upgradable, not exact
# version strings).

set -u

path="/opt/course/apt-research/upgradable.txt"

if [[ ! -e "$path" ]]; then
  echo "FAIL: upgradable list recorded - $path does not exist"
  exit 1
fi

expected=$(apt list --upgradable 2>/dev/null | grep -v '^Listing' | cut -d/ -f1 | sort -u)
recorded=$(grep -v '^Listing' "$path" 2>/dev/null | cut -d/ -f1 | sort -u)

if [[ "$recorded" != "$expected" ]]; then
  echo "FAIL: upgradable list recorded - recorded package set does not match the live upgradable set"
  echo "--- expected ---"
  echo "$expected"
  echo "--- recorded ---"
  echo "$recorded"
  exit 1
fi

echo "PASS: $path matches the live apt list --upgradable output"
exit 0
