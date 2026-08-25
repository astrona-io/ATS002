#!/usr/bin/env bash
# Confirms ops-monitor is in the docker group, a prerequisite for its cron
# job to run docker commands non-interactively without a permission error.

set -u

if ! id ops-monitor >/dev/null 2>&1; then
  echo "FAIL: ops-monitor docker access - user ops-monitor does not exist"
  exit 1
fi

if ! id ops-monitor | grep -q '(docker)'; then
  echo "FAIL: ops-monitor docker access - ops-monitor is not a member of the docker group"
  exit 1
fi

echo "PASS: ops-monitor is a member of the docker group"
exit 0
