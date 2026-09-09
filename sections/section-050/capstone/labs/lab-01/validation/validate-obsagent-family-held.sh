#!/usr/bin/env bash
# Confirms every installed obsagent-* package is present in
# `apt-mark showhold`, computed live against whatever the obsagent-*
# family actually is on this host rather than a hardcoded package list.

set -u

expected=$(apt list --installed 2>/dev/null | grep -E '^obsagent-' | cut -d/ -f1 | sort -u)

if [[ -z "$expected" ]]; then
  echo "FAIL: obsagent family held - no installed obsagent-* packages found to check against; bootstrap may not have run correctly"
  exit 1
fi

held=$(apt-mark showhold 2>/dev/null | sort -u)

fail=0
while IFS= read -r pkg; do
  if ! grep -qx "$pkg" <<<"$held"; then
    echo "FAIL: obsagent family held - '$pkg' is installed but not present in apt-mark showhold"
    fail=1
  fi
done <<<"$expected"

if [[ "$fail" -ne 0 ]]; then
  exit 1
fi

echo "PASS: every installed obsagent-* package is held (apt-mark showhold):"
echo "$expected"
exit 0
