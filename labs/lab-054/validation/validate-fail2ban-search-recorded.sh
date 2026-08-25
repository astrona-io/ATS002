#!/usr/bin/env bash
# Confirms /opt/course/apt-research/fail2ban-search.txt contains a genuine
# 'apt search fail2ban' hit -- specifically a line for the fail2ban
# package itself, not just any non-empty file.

set -u

path="/opt/course/apt-research/fail2ban-search.txt"

if [[ ! -s "$path" ]]; then
  echo "FAIL: fail2ban search recorded - $path is missing or empty"
  exit 1
fi

if ! grep -qE '^fail2ban/' "$path"; then
  echo "FAIL: fail2ban search recorded - $path does not contain a 'fail2ban/...' hit line (expected 'apt search fail2ban' output)"
  exit 1
fi

echo "PASS: $path contains a genuine fail2ban search hit"
exit 0
