#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
set -u

FILE=/opt/course/7/sleeper-pid

PID=$(pgrep -f /opt/crew/crew-sleeper.sh | head -1)
if [[ -z "$PID" ]]; then
  echo "FAIL: crew-sleeper.sh is not running (it must stay running)"
  exit 1
fi

if [[ ! -f "$FILE" ]]; then
  echo "FAIL: $FILE does not exist"
  exit 1
fi

CONTENT=$(tr -d '[:space:]' < "$FILE")
if [[ "$CONTENT" != "$PID" ]]; then
  echo "FAIL: $FILE holds '${CONTENT:-nothing}', expected the sleeper PID $PID"
  exit 1
fi

echo "PASS: $FILE holds the sleeper PID $PID"
exit 0
ASTRONA_STUDENT_SCRIPT
