#!/usr/bin/env bash
# Confirms frontend_v1 was stopped (not removed) via docker stop.

set -u

state="$(sudo docker inspect --format '{{ .State.Status }}' frontend_v1 2>/dev/null)"

if [[ -z "$state" ]]; then
  echo "FAIL: frontend_v1 stopped - container frontend_v1 does not exist (should exist, just stopped)"
  exit 1
fi

if [[ "$state" != "exited" ]]; then
  echo "FAIL: frontend_v1 stopped - status is '$state', expected 'exited'"
  exit 1
fi

echo "PASS: frontend_v1 is stopped (status=$state)"
exit 0
