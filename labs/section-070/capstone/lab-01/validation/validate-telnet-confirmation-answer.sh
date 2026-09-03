#!/usr/bin/env bash
set -u

if ! sudo docker ps --format '{{.Names}}' | grep -qx zypperbox; then
  echo "FAIL: zypperbox container is not running"
  exit 1
fi

answer=$(sudo docker exec zypperbox cat /root/answers/03-confirm-telnet-installed.txt 2>/dev/null)

if [ -z "$answer" ]; then
  echo "FAIL: /root/answers/03-confirm-telnet-installed.txt is empty or missing"
  exit 1
fi

# Expect a row for telnet-server explicitly marked installed ('i') in
# zypper's leading status column -- confirms an installed-only search was
# used, not a raw unfiltered search.
if ! echo "$answer" | grep -E '^i[[:space:]]*\|[[:space:]]*telnet-server'; then
  echo "FAIL: /root/answers/03-confirm-telnet-installed.txt does not show telnet-server marked installed"
  exit 1
fi

echo "PASS: /root/answers/03-confirm-telnet-installed.txt correctly confirms telnet-server as installed"
exit 0
