#!/usr/bin/env bash
# Confirms kernel.pid_max is raised live to at least 1048576 AND persisted
# in a config file under /etc/sysctl.d/ (or /etc/sysctl.conf) with a value
# that would win over the low bootstrap baseline.

set -u

threshold=1048576

live=$(sysctl -n kernel.pid_max 2>/dev/null || echo 0)

if [[ "$live" -lt "$threshold" ]]; then
  echo "FAIL: pid_max raised - live kernel.pid_max is '$live', expected >= $threshold"
  exit 1
fi

persisted=$(grep -rhE '^\s*kernel\.pid_max\s*=\s*[0-9]+' /etc/sysctl.d/ /etc/sysctl.conf 2>/dev/null | grep -vE '01-pid-max-baseline' | awk -F= '{gsub(/ /,"",$2); print $2}' | sort -n | tail -1)

if [[ -z "$persisted" || "$persisted" -lt "$threshold" ]]; then
  echo "FAIL: pid_max raised - no /etc/sysctl.d/*.conf (or /etc/sysctl.conf) file persists kernel.pid_max >= $threshold"
  exit 1
fi

echo "PASS: kernel.pid_max is $live live and persisted at $persisted"
exit 0
