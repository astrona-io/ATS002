#!/usr/bin/env bash
# Confirms collector1 and collector3 (which never call kill()) are still
# running with their executables intact -- penalizes "kill everything to
# be safe" instead of acting only on the confirmed offender.

set -u

fail=0

for name in collector1 collector3; do
  if ! pgrep -f "/usr/local/bin/${name}" >/dev/null 2>&1; then
    echo "FAIL: innocent processes untouched - ${name} is not running (it should not have been touched)"
    fail=1
  fi

  if [[ ! -e "/usr/local/bin/${name}" ]]; then
    echo "FAIL: innocent processes untouched - /usr/local/bin/${name} was removed (it should not have been touched)"
    fail=1
  fi
done

if [[ "$fail" -ne 0 ]]; then
  exit 1
fi

echo "PASS: collector1 and collector3 are still running with their executables intact"
exit 0
