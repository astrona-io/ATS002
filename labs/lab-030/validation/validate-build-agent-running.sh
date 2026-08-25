#!/usr/bin/env bash
# Confirms the build-agent domain was actually started, not just defined.

set -u

DOMAIN=build-agent

state=$(sudo virsh domstate "$DOMAIN" 2>/dev/null | tr -d '[:space:]')

if [[ "$state" != "running" ]]; then
  echo "FAIL: domain '$DOMAIN' state is '${state:-unset}', expected 'running'"
  exit 1
fi

echo "PASS: domain '$DOMAIN' is running"
exit 0
