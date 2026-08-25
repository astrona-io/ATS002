#!/usr/bin/env bash
# Confirms the compiled vmreport tool can actually query the real
# build-agent libvirt domain and correctly reports its running state --
# the integration point between this capstone's two skills.

set -u

BIN=/usr/local/bin/vmreport
DOMAIN=build-agent

if [ ! -x "$BIN" ]; then
  echo "FAIL: $BIN is not installed/executable, cannot run integration check"
  exit 1
fi

report_output=$(sudo "$BIN" "$DOMAIN" 2>&1)

if [[ "$report_output" != *"domain '$DOMAIN'"* ]]; then
  echo "FAIL: vmreport output did not reference domain '$DOMAIN': '$report_output'"
  exit 1
fi

if [[ "$report_output" != *"state=running"* ]]; then
  echo "FAIL: vmreport did not report '$DOMAIN' as running: '$report_output'"
  exit 1
fi

echo "PASS: vmreport correctly reports domain '$DOMAIN' as running"
exit 0
