#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Inspect protected state; user access checks select their target account explicitly.
sudo -n bash <<'GRADER_ROOT'
# Confirms the hung telemetry-agent process (stuck in pause()) has been
# terminated and, since the unit has no Restart=, has stayed dead.

set -u

if pgrep -f /usr/local/bin/telemetry-agent >/dev/null 2>&1; then
  echo "FAIL: telemetry-agent killed - telemetry-agent is still running"
  exit 1
fi

echo "PASS: telemetry-agent is terminated and not running"
exit 0
GRADER_ROOT
ASTRONA_STUDENT_SCRIPT
