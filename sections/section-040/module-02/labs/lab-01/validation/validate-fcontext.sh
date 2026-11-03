#!/usr/bin/env bash
# Confirms a semanage fcontext add rule: type httpd_sys_content_t for /srv/web
# and everything below it. Accepts -a or --add, and either option order.
set -u
f=/root/selinux-fix.sh
line="$(sudo grep -E '^[[:space:]]*(sudo[[:space:]]+)?semanage[[:space:]]+fcontext' "$f" 2>/dev/null | grep -E -- '(-a|--add)' | grep -E -- '(-t|--type)[[:space:]=]+httpd_sys_content_t' | grep -E '/srv/web' | head -n 1)"
if [[ -z "$line" ]]; then
  echo "FAIL: fcontext - no 'semanage fcontext -a -t httpd_sys_content_t' line for /srv/web found"
  exit 1
fi
if ! grep -qE '/srv/web\(/\.\*\)\?' <<<"$line"; then
  echo "FAIL: fcontext - the path pattern must cover the folder and everything below it, for example \"/srv/web(/.*)?\""
  exit 1
fi
echo "PASS: fcontext rule found: $line"
exit 0
