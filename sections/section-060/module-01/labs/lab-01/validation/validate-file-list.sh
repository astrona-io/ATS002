#!/usr/bin/env bash
# Confirms logship-agent's recorded file list contains its binary and
# config file inside rpmbox.

set -u

files=$(sudo docker exec rpmbox rpm -ql logship-agent 2>&1)
rc=$?

if [[ $rc -ne 0 ]]; then
  echo "FAIL: file list - rpm -ql logship-agent failed inside rpmbox ($files)"
  exit 1
fi

if ! grep -qx "/usr/bin/logship-agent" <<< "$files"; then
  echo "FAIL: file list - /usr/bin/logship-agent missing from logship-agent's file list"
  exit 1
fi

if ! grep -qx "/etc/logship-agent/agent.conf" <<< "$files"; then
  echo "FAIL: file list - /etc/logship-agent/agent.conf missing from logship-agent's file list"
  exit 1
fi

echo "PASS: logship-agent owns /usr/bin/logship-agent and /etc/logship-agent/agent.conf"
exit 0
