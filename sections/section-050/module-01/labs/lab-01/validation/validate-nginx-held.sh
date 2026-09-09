#!/usr/bin/env bash
# Confirms nginx appears in apt-mark showhold.

set -u

if apt-mark showhold 2>/dev/null | grep -qx nginx; then
  echo "PASS: nginx is held (apt-mark showhold lists it)"
  exit 0
fi

echo "FAIL: nginx held - 'nginx' not present in apt-mark showhold output"
exit 1
