#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Inspect protected state; user access checks select their target account explicitly.
sudo -n bash <<'GRADER_ROOT'
# Confirms lingering is enabled for the user pilot.

set -u
cd /tmp

linger="$(loginctl show-user pilot --property=Linger --value 2>/dev/null || true)"
if [[ -z "$linger" && -f /var/lib/systemd/linger/pilot ]]; then
  linger="yes"
fi

if [[ "$linger" != "yes" ]]; then
  echo "FAIL: lingering for pilot is '${linger:-off}', expected 'yes'"
  exit 1
fi

echo "PASS: lingering is enabled for pilot"
exit 0
GRADER_ROOT
ASTRONA_STUDENT_SCRIPT
