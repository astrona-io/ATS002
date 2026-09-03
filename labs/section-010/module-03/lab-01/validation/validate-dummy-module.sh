#!/usr/bin/env bash
# Confirms the dummy module is loaded live with numdummies=2, and that both
# the load and the parameter are persisted for future boots.

set -u

if ! lsmod | grep -qw dummy; then
  echo "FAIL: dummy module - not currently loaded"
  exit 1
fi

param=$(cat /sys/module/dummy/parameters/numdummies 2>/dev/null || echo "")
if [[ "$param" != "2" ]]; then
  echo "FAIL: dummy module - numdummies parameter is '$param', expected '2'"
  exit 1
fi

if ! grep -rqw 'dummy' /etc/modules-load.d/ 2>/dev/null; then
  echo "FAIL: dummy module - no /etc/modules-load.d/*.conf file persists the module load"
  exit 1
fi

if ! grep -rqE 'options\s+dummy\s+numdummies=2' /etc/modprobe.d/ 2>/dev/null; then
  echo "FAIL: dummy module - no /etc/modprobe.d/*.conf file persists 'options dummy numdummies=2'"
  exit 1
fi

echo "PASS: dummy module is loaded with numdummies=2 and persisted via modules-load.d/modprobe.d"
exit 0
