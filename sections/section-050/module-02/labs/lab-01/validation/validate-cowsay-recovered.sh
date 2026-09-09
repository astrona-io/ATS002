#!/usr/bin/env bash
# Confirms the previously half-configured cowsay package now shows a
# clean "ii" (install ok installed) status, and that no package on the
# system is left in any pending/incomplete state.

set -u

status=$(dpkg-query -W -f='${Status}' cowsay 2>/dev/null || echo "")

if [[ "$status" != "install ok installed" ]]; then
  echo "FAIL: cowsay recovered - status is '$status', expected 'install ok installed'"
  exit 1
fi

audit_output=$(sudo dpkg --audit 2>/dev/null || true)
if [[ -n "$audit_output" ]]; then
  echo "FAIL: cowsay recovered - 'dpkg --audit' still reports packages needing attention:"
  echo "$audit_output"
  exit 1
fi

echo "PASS: cowsay is fully configured (ii) and dpkg --audit reports no outstanding issues"
exit 0
