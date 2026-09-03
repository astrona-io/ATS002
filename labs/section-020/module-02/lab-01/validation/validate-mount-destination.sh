#!/usr/bin/env bash
# Checks /opt/course/11/mount-destination against frontend_v2's actual
# first (and only) volume mount destination.

set -u

path="/opt/course/11/mount-destination"

if [[ ! -f "$path" ]]; then
  echo "FAIL: mount-destination - $path does not exist"
  exit 1
fi

expected="$(sudo docker inspect --format '{{ (index .Mounts 0).Destination }}' frontend_v2 2>/dev/null)"

if [[ -z "$expected" ]]; then
  echo "FAIL: mount-destination - could not determine frontend_v2's actual mount destination to compare against"
  exit 1
fi

actual="$(tr -d '[:space:]' < "$path")"

if [[ "$actual" == "$expected" ]]; then
  echo "PASS: mount-destination ($path = '$actual')"
  exit 0
else
  echo "FAIL: mount-destination - $path = '$actual', expected '$expected'"
  exit 1
fi
