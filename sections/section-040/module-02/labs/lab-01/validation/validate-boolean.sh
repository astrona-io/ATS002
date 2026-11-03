#!/usr/bin/env bash
# Confirms setsebool -P (persistent) turns httpd_can_network_connect on.
# Accepts -P in any position, and on, 1 or true.
set -u
f=/root/selinux-fix.sh
line="$(sudo grep -E '^[[:space:]]*(sudo[[:space:]]+)?setsebool[[:space:]]' "$f" 2>/dev/null | grep -E 'httpd_can_network_connect' | head -n 1)"
if [[ -z "$line" ]]; then
  echo "FAIL: boolean - no setsebool line for httpd_can_network_connect found"
  exit 1
fi
if ! grep -qE '(^|[[:space:]])-[A-Za-z]*P[A-Za-z]*([[:space:]]|$)' <<<"$line"; then
  echo "FAIL: boolean - the -P option is missing, so the change is lost at reboot"
  exit 1
fi
if ! grep -qE 'httpd_can_network_connect[[:space:]=]+(on|1|true)([[:space:]]|$)' <<<"$line" \
   && ! grep -qE '(on|1|true)[[:space:]]+httpd_can_network_connect' <<<"$line"; then
  echo "FAIL: boolean - the value must be on (or 1)"
  exit 1
fi
echo "PASS: boolean set persistently: $line"
exit 0
