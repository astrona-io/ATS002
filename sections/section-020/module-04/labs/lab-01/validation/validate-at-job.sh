#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Inspect protected state; user access checks select their target account explicitly.
sudo -n bash <<'GRADER_ROOT'
set -u

SCRIPT=/usr/local/sbin/archive-logs.sh

JOB_IDS=$(atq 2>/dev/null | grep ' 03:00:00 ' | awk '{print $1}')
if [[ -z "$JOB_IDS" ]]; then
  echo "FAIL: no at job is queued for 03:00 (atq shows none)"
  exit 1
fi

for job_id in $JOB_IDS; do
  if at -c "$job_id" 2>/dev/null | grep -q "$SCRIPT"; then
    echo "PASS: at job $job_id runs $SCRIPT at 03:00"
    exit 0
  fi
done

echo "FAIL: no job queued for 03:00 calls $SCRIPT"
exit 1
GRADER_ROOT
ASTRONA_STUDENT_SCRIPT
