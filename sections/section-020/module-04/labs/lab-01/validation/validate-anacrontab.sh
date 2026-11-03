#!/usr/bin/env bash
set -u

FILE=/etc/anacrontab

if ! grep -Eq '^7[[:space:]]+10[[:space:]]+weekly-archive[[:space:]]+/usr/local/sbin/archive-logs\.sh' "$FILE"; then
  echo "FAIL: $FILE has no line '7 10 weekly-archive /usr/local/sbin/archive-logs.sh'"
  exit 1
fi

if ! anacron -T >/dev/null 2>&1; then
  echo "FAIL: anacron -T rejects $FILE"
  exit 1
fi

echo "PASS: $FILE has the weekly-archive job and anacron -T accepts it"
exit 0
