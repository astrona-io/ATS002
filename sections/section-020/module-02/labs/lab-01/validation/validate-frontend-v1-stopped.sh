#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Inspect protected state; user access checks select their target account explicitly.
sudo -n bash <<'GRADER_ROOT'
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
GRADER_ROOT
ASTRONA_STUDENT_SCRIPT
