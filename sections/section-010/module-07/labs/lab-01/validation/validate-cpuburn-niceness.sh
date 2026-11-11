#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Inspect protected state; user access checks select their target account explicitly.
sudo -n bash <<'GRADER_ROOT'
set -u

PID=$(pgrep -f /opt/crew/cpuburn.sh | head -1)
if [[ -z "$PID" ]]; then
  echo "FAIL: cpuburn.sh is not running (it must stay running)"
  exit 1
fi

NICENESS=$(ps -o ni= -p "$PID" | tr -d ' ')
if [[ "$NICENESS" != "15" ]]; then
  echo "FAIL: cpuburn.sh (PID $PID) has niceness '${NICENESS:-unset}', expected 15"
  exit 1
fi

echo "PASS: cpuburn.sh is running with niceness 15"
exit 0
GRADER_ROOT
ASTRONA_STUDENT_SCRIPT
