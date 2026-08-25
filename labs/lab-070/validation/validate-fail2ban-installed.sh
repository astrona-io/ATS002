#!/usr/bin/env bash
set -u

if ! sudo docker ps --format '{{.Names}}' | grep -qx zypperbox; then
  echo "FAIL: zypperbox container is not running"
  exit 1
fi

if sudo docker exec zypperbox rpm -q fail2ban >/dev/null 2>&1; then
  echo "PASS: fail2ban is installed inside zypperbox"
  exit 0
fi

echo "FAIL: fail2ban is not installed inside zypperbox"
exit 1
