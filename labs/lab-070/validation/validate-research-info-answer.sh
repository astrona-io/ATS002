#!/usr/bin/env bash
set -u

if ! sudo docker ps --format '{{.Names}}' | grep -qx zypperbox; then
  echo "FAIL: zypperbox container is not running"
  exit 1
fi

answer=$(sudo docker exec zypperbox cat /root/answers/02-research-info.txt 2>/dev/null)

if [ -z "$answer" ]; then
  echo "FAIL: /root/answers/02-research-info.txt is empty or missing"
  exit 1
fi

if ! echo "$answer" | grep -qi 'fail2ban'; then
  echo "FAIL: /root/answers/02-research-info.txt does not mention fail2ban"
  exit 1
fi

if ! echo "$answer" | grep -qi 'Version'; then
  echo "FAIL: /root/answers/02-research-info.txt does not contain a Version field"
  exit 1
fi

echo "PASS: /root/answers/02-research-info.txt records zypper info metadata for fail2ban"
exit 0
