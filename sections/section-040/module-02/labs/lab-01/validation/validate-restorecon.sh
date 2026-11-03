#!/usr/bin/env bash
# Confirms restorecon runs recursively on /srv/web, on a line after the
# semanage fcontext rule. Accepts -R, -Rv, -vR, -r.
set -u
f=/root/selinux-fix.sh
rule_no="$(sudo grep -nE '^[[:space:]]*(sudo[[:space:]]+)?semanage[[:space:]]+fcontext' "$f" 2>/dev/null | head -n 1 | cut -d: -f1)"
rc_no="$(sudo grep -nE '^[[:space:]]*(sudo[[:space:]]+)?restorecon[[:space:]]+(-[A-Za-z]*[Rr][A-Za-z]*)[[:space:]].*/srv/web' "$f" 2>/dev/null | tail -n 1 | cut -d: -f1)"
if [[ -z "$rc_no" ]]; then
  echo "FAIL: restorecon - no recursive 'restorecon -R... /srv/web' line found"
  exit 1
fi
if [[ -z "$rule_no" || "$rc_no" -le "$rule_no" ]]; then
  echo "FAIL: restorecon - it must come after the semanage fcontext rule, or it relabels with the old rule"
  exit 1
fi
echo "PASS: restorecon runs recursively on /srv/web after the rule"
exit 0
