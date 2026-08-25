#!/usr/bin/env bash
# Confirms logship-agent-2.1.0-1.x86_64 is installed inside rpmbox.

set -u

nvr=$(sudo docker exec rpmbox rpm -q logship-agent 2>&1)
rc=$?

if [[ $rc -ne 0 ]]; then
  echo "FAIL: installed - logship-agent is not installed inside rpmbox ($nvr)"
  exit 1
fi

if [[ "$nvr" != "logship-agent-2.1.0-1.x86_64" ]]; then
  echo "FAIL: installed - unexpected NVR '$nvr', expected logship-agent-2.1.0-1.x86_64"
  exit 1
fi

echo "PASS: $nvr is installed inside rpmbox"
exit 0
