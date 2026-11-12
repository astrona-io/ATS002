#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Inspect protected state; user access checks select their target account explicitly.
sudo -n bash <<'GRADER_ROOT'
# Confirms no trace of the old system-wide nightly-sync.sh cron entry
# remains in /etc/crontab or /etc/cron.d/, so the job cannot fire twice.

set -u

hits="$(sudo grep -rn 'nightly-sync\.sh' /etc/crontab /etc/cron.d/ 2>/dev/null || true)"

if [[ -n "$hits" ]]; then
  echo "FAIL: old system-wide cron entry still present:"
  echo "$hits"
  exit 1
fi

echo "PASS: no trace of the old system-wide nightly-sync.sh cron entry remains in /etc/crontab or /etc/cron.d/"
exit 0
GRADER_ROOT
ASTRONA_STUDENT_SCRIPT
