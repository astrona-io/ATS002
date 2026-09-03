#!/usr/bin/env bash
# Confirms fail2ban is installed inside rpmbox.

set -u

if ! sudo docker exec rpmbox rpm -q fail2ban >/dev/null 2>&1; then
  echo "FAIL: fail2ban installed - fail2ban is not installed inside rpmbox"
  exit 1
fi

echo "PASS: fail2ban is installed inside rpmbox"
exit 0
