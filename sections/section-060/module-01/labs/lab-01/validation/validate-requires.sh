#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Inspect protected state; user access checks select their target account explicitly.
sudo -n bash <<'GRADER_ROOT'
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
GRADER_ROOT
ASTRONA_STUDENT_SCRIPT
