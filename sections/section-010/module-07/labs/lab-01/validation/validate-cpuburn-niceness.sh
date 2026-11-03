#!/usr/bin/env bash
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
