#!/usr/bin/env bash
# Confirms the hung telemetry-agent process (stuck in pause()) has been
# terminated and, since the unit has no Restart=, has stayed dead.

set -u

if pgrep -f /usr/local/bin/telemetry-agent >/dev/null 2>&1; then
  echo "FAIL: telemetry-agent killed - telemetry-agent is still running"
  exit 1
fi

echo "PASS: telemetry-agent is terminated and not running"
exit 0
