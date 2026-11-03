#!/usr/bin/env bash
set -u

if [[ -e /etc/cron.allow ]]; then
  echo "FAIL: /etc/cron.allow exists (it must not, or cron.deny is ignored)"
  exit 1
fi

if [[ ! -f /etc/cron.deny ]]; then
  echo "FAIL: /etc/cron.deny does not exist"
  exit 1
fi

if ! grep -Eq '^[[:space:]]*ops-monitor[[:space:]]*$' /etc/cron.deny; then
  echo "FAIL: ops-monitor is not listed in /etc/cron.deny"
  exit 1
fi

echo "PASS: ops-monitor is listed in /etc/cron.deny and no cron.allow exists"
exit 0
