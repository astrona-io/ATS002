#!/usr/bin/env bash
set -u

if ! sudo docker ps --format '{{.Names}}' | grep -qx zypperbox; then
  echo "FAIL: zypperbox container is not running"
  exit 1
fi

history_log=$(sudo docker exec zypperbox cat /var/log/zypp/history 2>/dev/null)

if [ -z "$history_log" ]; then
  echo "FAIL: /var/log/zypp/history is empty or missing inside zypperbox"
  exit 1
fi

# Each zypp history line is pipe-delimited with the action type (install,
# remove, patch, ...) as the second field. Match the action column and the
# package name loosely on the same line, rather than depending on an exact
# column count, since column count varies slightly between line types.
if ! echo "$history_log" | grep -E '^[^|]+\|install\|' | grep -qi 'fail2ban'; then
  echo "FAIL: zypper history has no 'install' entry for fail2ban"
  exit 1
fi

if ! echo "$history_log" | grep -E '^[^|]+\|remove\|' | grep -qi 'telnet-server'; then
  echo "FAIL: zypper history has no 'remove' entry for telnet-server"
  exit 1
fi

echo "PASS: zypper history log records the fail2ban install and telnet-server removal"
exit 0
