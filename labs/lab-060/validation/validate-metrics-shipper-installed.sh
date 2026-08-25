#!/usr/bin/env bash
# Confirms metrics-shipper-1.4.0-1.x86_64 is installed inside rpmbox and
# its files verify clean against what was recorded at install time.

set -u

nvr=$(sudo docker exec rpmbox rpm -q metrics-shipper 2>&1)
rc=$?

if [[ $rc -ne 0 ]]; then
  echo "FAIL: metrics-shipper installed - metrics-shipper is not installed inside rpmbox ($nvr)"
  exit 1
fi

if [[ "$nvr" != "metrics-shipper-1.4.0-1.x86_64" ]]; then
  echo "FAIL: metrics-shipper installed - unexpected NVR '$nvr', expected metrics-shipper-1.4.0-1.x86_64"
  exit 1
fi

verify_output=$(sudo docker exec rpmbox rpm -V metrics-shipper 2>&1)
verify_rc=$?

if [[ $verify_rc -ne 0 || -n "$verify_output" ]]; then
  echo "FAIL: metrics-shipper installed - rpm -V metrics-shipper reported drift or an error:"
  echo "$verify_output"
  exit 1
fi

echo "PASS: $nvr is installed inside rpmbox and verifies clean"
exit 0
