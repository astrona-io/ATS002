#!/usr/bin/env bash
# Confirms semanage port adds tcp 8888 with type http_port_t.
set -u
f=/root/selinux-fix.sh
line="$(sudo grep -E '^[[:space:]]*(sudo[[:space:]]+)?semanage[[:space:]]+port' "$f" 2>/dev/null | grep -E -- '(-a|--add)' | grep -E -- '(-t|--type)[[:space:]=]+http_port_t' | grep -E -- '(-p|--proto)[[:space:]=]+tcp' | grep -E '(^|[[:space:]])8888([[:space:]]|$)' | head -n 1)"
if [[ -z "$line" ]]; then
  echo "FAIL: port - no 'semanage port -a -t http_port_t -p tcp 8888' line found"
  exit 1
fi
echo "PASS: port rule found: $line"
exit 0
