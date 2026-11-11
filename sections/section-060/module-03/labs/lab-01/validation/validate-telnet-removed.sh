#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Confirms telnet has been fully removed inside rpmbox.

set -u

if sudo docker exec rpmbox rpm -q telnet >/dev/null 2>&1; then
  echo "FAIL: telnet removed - telnet is still installed inside rpmbox"
  exit 1
fi

echo "PASS: telnet is not installed inside rpmbox"
exit 0
ASTRONA_STUDENT_SCRIPT
