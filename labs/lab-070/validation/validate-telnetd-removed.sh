#!/usr/bin/env bash
set -u

if ! sudo docker ps --format '{{.Names}}' | grep -qx zypperbox; then
  echo "FAIL: zypperbox container is not running"
  exit 1
fi

if sudo docker exec zypperbox rpm -q telnet-server >/dev/null 2>&1; then
  echo "FAIL: telnet-server (the telnetd daemon package) is still installed inside zypperbox"
  exit 1
fi

echo "PASS: telnet-server has been removed from zypperbox"
exit 0
