#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
set -u

if pgrep -f /opt/crew/stubborn.sh >/dev/null; then
  echo "FAIL: a process running /opt/crew/stubborn.sh is still alive"
  exit 1
fi

echo "PASS: no stubborn.sh process is running"
exit 0
ASTRONA_STUDENT_SCRIPT
