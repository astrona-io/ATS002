#!/usr/bin/env bash
# Confirms every installed php8.1-* package is present in
# `apt-mark showhold`, computed live against whatever the php8.1-*
# family actually is on this host rather than a hardcoded package list.

set -u

expected=$(apt list --installed 2>/dev/null | grep -E '^php8\.1-' | cut -d/ -f1 | sort -u)

if [[ -z "$expected" ]]; then
  echo "FAIL: php8.1 family held - no installed php8.1-* packages found to check against; bootstrap may not have run correctly"
  exit 1
fi

held=$(apt-mark showhold 2>/dev/null | sort -u)

fail=0
while IFS= read -r pkg; do
  if ! grep -qx "$pkg" <<<"$held"; then
    echo "FAIL: php8.1 family held - '$pkg' is installed but not present in apt-mark showhold"
    fail=1
  fi
done <<<"$expected"

if [[ "$fail" -ne 0 ]]; then
  exit 1
fi

echo "PASS: every installed php8.1-* package is held (apt-mark showhold):"
echo "$expected"
exit 0
