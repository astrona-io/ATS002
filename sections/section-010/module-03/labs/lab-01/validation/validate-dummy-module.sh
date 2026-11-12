#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Inspect protected state; user access checks select their target account explicitly.
sudo -n bash <<'GRADER_ROOT'
# Confirms the dummy module is loaded live with numdummies=2, and that both
# the load and the parameter are persisted for future boots.

set -u

if ! test -d /sys/module/dummy; then
  echo "FAIL: dummy module - not currently loaded"
  exit 1
fi

param=$(ip -o link show type dummy | wc -l | tr -d ' ')
if [[ "$param" != "2" ]]; then
  echo "FAIL: dummy module - dummy interface count is '$param', expected '2'"
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
GRADER_ROOT
ASTRONA_STUDENT_SCRIPT
