#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Confirms nginx appears in apt-mark showhold.

set -u

if apt-mark showhold 2>/dev/null | grep -qx nginx; then
  echo "PASS: nginx is held (apt-mark showhold lists it)"
  exit 0
fi

echo "FAIL: nginx held - 'nginx' not present in apt-mark showhold output"
exit 1
ASTRONA_STUDENT_SCRIPT
