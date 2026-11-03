#!/usr/bin/env bash
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
