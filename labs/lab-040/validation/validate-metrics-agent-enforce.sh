#!/usr/bin/env bash
set -u

PROFILE="/usr/sbin/metrics-agent"

AA_STATUS=$(sudo aa-status 2>/dev/null)
if [ -z "$AA_STATUS" ]; then
  echo "FAIL: unable to read aa-status output -- is AppArmor running?"
  exit 1
fi

ENFORCE_BLOCK=$(printf '%s\n' "$AA_STATUS" | sed -n '/profiles are in enforce mode\./,/profiles are in complain mode\.\|processes have profiles defined\./p')
if ! printf '%s\n' "$ENFORCE_BLOCK" | grep -q "$PROFILE"; then
  echo "FAIL: $PROFILE is not loaded in enforce mode"
  exit 1
fi

COMPLAIN_BLOCK=$(printf '%s\n' "$AA_STATUS" | sed -n '/profiles are in complain mode\./,/processes have profiles defined\./p')
if printf '%s\n' "$COMPLAIN_BLOCK" | grep -q "$PROFILE"; then
  echo "FAIL: $PROFILE was left in complain mode instead of enforce"
  exit 1
fi

if ! systemctl is-active --quiet metrics-agent; then
  echo "FAIL: metrics-agent.service is not active"
  exit 1
fi

echo "PASS: metrics-agent's AppArmor profile is loaded and genuinely enforcing"
exit 0
