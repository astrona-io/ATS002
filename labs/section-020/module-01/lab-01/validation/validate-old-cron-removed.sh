#!/usr/bin/env bash
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
