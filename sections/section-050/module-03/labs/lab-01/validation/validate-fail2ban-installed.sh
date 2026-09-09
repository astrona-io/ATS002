#!/usr/bin/env bash
# Confirms fail2ban is now cleanly installed.

set -u

status=$(dpkg-query -W -f='${Status}' fail2ban 2>/dev/null || echo "")

if [[ "$status" != "install ok installed" ]]; then
  echo "FAIL: fail2ban installed - status is '$status', expected 'install ok installed'"
  exit 1
fi

echo "PASS: fail2ban is installed"
exit 0
