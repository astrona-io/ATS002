#!/usr/bin/env bash
# Confirms logship-agent declares its expected Requires (bash, coreutils)
# inside rpmbox.

set -u

requires=$(sudo docker exec rpmbox rpm -q --requires logship-agent 2>&1)
rc=$?

if [[ $rc -ne 0 ]]; then
  echo "FAIL: requires - rpm -q --requires logship-agent failed inside rpmbox ($requires)"
  exit 1
fi

if ! grep -q "^bash" <<< "$requires"; then
  echo "FAIL: requires - logship-agent does not declare a requirement on bash"
  exit 1
fi

if ! grep -q "^coreutils" <<< "$requires"; then
  echo "FAIL: requires - logship-agent does not declare a requirement on coreutils"
  exit 1
fi

echo "PASS: logship-agent declares Requires on bash and coreutils"
exit 0
