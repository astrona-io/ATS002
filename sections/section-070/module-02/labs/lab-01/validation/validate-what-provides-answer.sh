#!/usr/bin/env bash
set -u

if ! sudo docker ps --format '{{.Names}}' | grep -qx zypperbox; then
  echo "FAIL: zypperbox container is not running"
  exit 1
fi

answer=$(sudo docker exec zypperbox cat /root/answers/03-what-provides.txt 2>/dev/null)

if [ -z "$answer" ]; then
  echo "FAIL: /root/answers/03-what-provides.txt is empty or missing"
  exit 1
fi

if ! echo "$answer" | grep -qi 'iproute2'; then
  echo "FAIL: /root/answers/03-what-provides.txt does not name iproute2 as the provider of /usr/sbin/ip"
  exit 1
fi

echo "PASS: /root/answers/03-what-provides.txt correctly identifies iproute2"
exit 0
