#!/usr/bin/env bash
# Checks /opt/course/timezone against timedatectl (falls back to /etc/timezone)

set -u

path="/opt/course/timezone"
expected="$(timedatectl show --property=Timezone --value 2>/dev/null || cat /etc/timezone)"

if [[ ! -f "$path" ]]; then
  echo "FAIL: timezone - $path does not exist"
  exit 1
fi

actual="$(cat "$path")"

if [[ "$actual" == "$expected" ]]; then
  echo "PASS: timezone ($path = '$actual')"
  exit 0
else
  echo "FAIL: timezone - $path = '$actual', expected '$expected'"
  exit 1
fi
