#!/usr/bin/env bash
# Checks /opt/course/ip_forward equals 1 (bootstrap sets net.ipv4.ip_forward=1)

set -u

path="/opt/course/ip_forward"
expected="1"

if [[ ! -f "$path" ]]; then
  echo "FAIL: ip_forward - $path does not exist"
  exit 1
fi

actual="$(cat "$path")"

if [[ "$actual" == "$expected" ]]; then
  echo "PASS: ip_forward ($path = '$actual')"
  exit 0
else
  echo "FAIL: ip_forward - $path = '$actual', expected '$expected'"
  exit 1
fi
