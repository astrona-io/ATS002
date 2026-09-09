#!/usr/bin/env bash
# Functional proof: stops billing_v2 to simulate a crash, then polls for
# up to ~100 seconds to confirm the scheduled cron job actually brings it
# back up on its own - the real test of "correct cron scheduling AND
# correct container lifecycle management working together."

set -u

if ! sudo docker inspect billing_v2 >/dev/null 2>&1; then
  echo "FAIL: auto-recovery - billing_v2 does not exist, cannot test recovery"
  exit 1
fi

sudo docker stop billing_v2 >/dev/null 2>&1

recovered=0
for _ in $(seq 1 20); do
  sleep 5
  state="$(sudo docker inspect --format '{{ .State.Running }}' billing_v2 2>/dev/null)"
  if [[ "$state" == "true" ]]; then
    recovered=1
    break
  fi
done

if [[ "$recovered" -ne 1 ]]; then
  echo "FAIL: auto-recovery - billing_v2 was stopped to simulate a crash but did not come back up within ~100 seconds; check ops-monitor's crontab and the health-check script"
  exit 1
fi

echo "PASS: billing_v2 automatically recovered after being stopped, confirming the scheduled cron job works end-to-end"
exit 0
