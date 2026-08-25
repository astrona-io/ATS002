#!/usr/bin/env bash
set -u

if ! sudo docker ps --format '{{.Names}}' | grep -qx zypperbox; then
  echo "FAIL: zypperbox container is not running"
  exit 1
fi

answer=$(sudo docker exec zypperbox cat /root/answers/02-info.txt 2>/dev/null)

if [ -z "$answer" ]; then
  echo "FAIL: /root/answers/02-info.txt is empty or missing"
  exit 1
fi

if ! echo "$answer" | grep -qi '^Name.*: *nginx$'; then
  echo "FAIL: /root/answers/02-info.txt does not contain a 'Name : nginx' metadata line"
  exit 1
fi

if ! echo "$answer" | grep -qi 'Version'; then
  echo "FAIL: /root/answers/02-info.txt does not contain a Version field"
  exit 1
fi

# This lab is entirely read-only -- nginx must never have actually been
# installed while researching it.
if sudo docker exec zypperbox rpm -q nginx >/dev/null 2>&1; then
  echo "FAIL: nginx is installed inside zypperbox -- this lab is research-only"
  exit 1
fi

echo "PASS: /root/answers/02-info.txt records nginx metadata, and nginx was never installed"
exit 0
