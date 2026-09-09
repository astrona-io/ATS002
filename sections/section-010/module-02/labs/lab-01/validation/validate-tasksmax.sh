#!/usr/bin/env bash
# Confirms data-ingest.service's systemd TasksMax cgroup ceiling has been
# raised (to "infinity" or at least 65536) and applied to the running unit.

set -u

threshold=65536

prop=$(systemctl show data-ingest.service --property=TasksMax --value 2>/dev/null)

if [[ -z "$prop" ]]; then
  echo "FAIL: TasksMax raised - could not read TasksMax for data-ingest.service"
  exit 1
fi

if [[ "$prop" == "infinity" ]]; then
  echo "PASS: data-ingest.service TasksMax is infinity"
  exit 0
fi

if [[ "$prop" =~ ^[0-9]+$ ]] && [[ "$prop" -ge "$threshold" ]]; then
  echo "PASS: data-ingest.service TasksMax is $prop"
  exit 0
fi

echo "FAIL: TasksMax raised - data-ingest.service TasksMax is '$prop', expected 'infinity' or >= $threshold"
exit 1
