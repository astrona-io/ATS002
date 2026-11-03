#!/usr/bin/env bash
# Confirms /root/selinux-fix.sh exists, is not empty and passes bash -n.
set -u
f=/root/selinux-fix.sh
if ! sudo test -s "$f"; then
  echo "FAIL: syntax - $f is missing or empty"
  exit 1
fi
if ! sudo bash -n "$f" 2>/dev/null; then
  echo "FAIL: syntax - bash -n reports an error in $f"
  exit 1
fi
echo "PASS: $f exists and has valid shell syntax"
exit 0
