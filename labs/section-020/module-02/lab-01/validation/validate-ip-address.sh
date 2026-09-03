#!/usr/bin/env bash
# Checks /opt/course/11/ip-address against frontend_v2's actual assigned
# IP address (default-bridge field, falling back to the per-network map).

set -u

path="/opt/course/11/ip-address"

if [[ ! -f "$path" ]]; then
  echo "FAIL: ip-address - $path does not exist"
  exit 1
fi

expected="$(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' frontend_v2 2>/dev/null)"

if [[ -z "$expected" ]]; then
  expected="$(sudo docker inspect --format '{{ range .NetworkSettings.Networks }}{{ .IPAddress }}{{ end }}' frontend_v2 2>/dev/null)"
fi

if [[ -z "$expected" ]]; then
  echo "FAIL: ip-address - could not determine frontend_v2's actual IP address to compare against"
  exit 1
fi

actual="$(tr -d '[:space:]' < "$path")"

if [[ "$actual" == "$expected" ]]; then
  echo "PASS: ip-address ($path = '$actual')"
  exit 0
else
  echo "FAIL: ip-address - $path = '$actual', expected '$expected'"
  exit 1
fi
