#!/usr/bin/env bash
# Confirms /opt/course/audit/kernel-release matches `uname -r` and
# /opt/course/audit/vm-swappiness matches the live vm.swappiness value.

set -u

fail=0

krel_path="/opt/course/audit/kernel-release"
krel_expected="$(uname -r)"

if [[ ! -f "$krel_path" ]]; then
  echo "FAIL: audit files - $krel_path does not exist"
  fail=1
else
  krel_actual="$(cat "$krel_path")"
  if [[ "$krel_actual" == "$krel_expected" ]]; then
    echo "PASS: audit files - kernel-release ($krel_path = '$krel_actual')"
  else
    echo "FAIL: audit files - $krel_path = '$krel_actual', expected '$krel_expected'"
    fail=1
  fi
fi

swap_path="/opt/course/audit/vm-swappiness"
swap_expected="$(sysctl -n vm.swappiness 2>/dev/null || cat /proc/sys/vm/swappiness)"

if [[ ! -f "$swap_path" ]]; then
  echo "FAIL: audit files - $swap_path does not exist"
  fail=1
else
  swap_actual="$(cat "$swap_path")"
  if [[ "$swap_actual" == "$swap_expected" ]]; then
    echo "PASS: audit files - vm-swappiness ($swap_path = '$swap_actual')"
  else
    echo "FAIL: audit files - $swap_path = '$swap_actual', expected '$swap_expected'"
    fail=1
  fi
fi

if [[ "$fail" -ne 0 ]]; then
  exit 1
fi

exit 0
