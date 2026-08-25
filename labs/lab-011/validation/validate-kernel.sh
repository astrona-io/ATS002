#!/usr/bin/env bash
# Checks /opt/course/kernel against `uname -r`

set -u

path="/opt/course/kernel"
expected="$(uname -r)"

if [[ ! -f "$path" ]]; then
  echo "FAIL: kernel release - $path does not exist"
  exit 1
fi

actual="$(cat "$path")"

if [[ "$actual" == "$expected" ]]; then
  echo "PASS: kernel release ($path = '$actual')"
  exit 0
else
  echo "FAIL: kernel release - $path = '$actual', expected '$expected'"
  exit 1
fi
