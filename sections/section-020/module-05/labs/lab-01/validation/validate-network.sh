#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Inspect protected state; user access checks select their target account explicitly.
sudo -n bash <<'GRADER_ROOT'
# Confirms status-web is attached to the user-defined network status-net.

set -u

if ! sudo docker network inspect status-net >/dev/null 2>&1; then
  echo "FAIL: network status-net does not exist"
  exit 1
fi

nets="$(sudo docker inspect --format '{{ range $name, $conf := .NetworkSettings.Networks }}{{ $name }} {{ end }}' status-web 2>/dev/null)"
if ! grep -qw 'status-net' <<<"$nets"; then
  echo "FAIL: status-web is on '$nets', expected status-net"
  exit 1
fi

echo "PASS: status-web is on the network status-net"
exit 0
GRADER_ROOT
ASTRONA_STUDENT_SCRIPT
