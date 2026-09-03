#!/usr/bin/env bash
# Confirms the decommissioned billing_v1 container was fully retired
# (stopped AND removed), not just stopped - it was squatting on the port
# billing_v2 needs, so a merely-stopped container would still be wrong.

set -u

if sudo docker inspect billing_v1 >/dev/null 2>&1; then
  echo "FAIL: billing_v1 retired - container still exists (should be stopped and removed)"
  exit 1
fi

echo "PASS: billing_v1 no longer exists"
exit 0
