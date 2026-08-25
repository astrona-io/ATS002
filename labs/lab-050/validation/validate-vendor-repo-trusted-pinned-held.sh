#!/usr/bin/env bash
# Confirms: (1) modern signed-by trust is configured (a sources.list.d
# entry references a dedicated keyring under /etc/apt/keyrings/, not the
# deprecated apt-key global keyring), (2) telemetry-agent is installed at
# exactly the vendor-published version recorded during bootstrap, and
# (3) it is held.

set -u

fail=0

# --- 1. Modern trust ---
list_match=""
for f in /etc/apt/sources.list.d/*.list; do
  [[ -e "$f" ]] || continue
  if grep -qE 'signed-by=/etc/apt/keyrings/[^]]+\.gpg' "$f" 2>/dev/null; then
    list_match="$f"
    break
  fi
done

if [[ -z "$list_match" ]]; then
  echo "FAIL: vendor repo trusted/pinned/held - no /etc/apt/sources.list.d/*.list file uses a signed-by=/etc/apt/keyrings/*.gpg keyring"
  fail=1
else
  keyring_path=$(grep -oE 'signed-by=/etc/apt/keyrings/[^]]+\.gpg' "$list_match" | head -1 | cut -d= -f2)
  if [[ ! -s "$keyring_path" ]] || ! gpg --show-keys "$keyring_path" >/dev/null 2>&1; then
    echo "FAIL: vendor repo trusted/pinned/held - referenced keyring '$keyring_path' is missing or not a valid GPG keyring"
    fail=1
  fi
fi

# --- 2. Pinned exact version ---
expected=$(cat /opt/lab-meta/telemetry-agent-vendor-version 2>/dev/null)

if [[ -z "$expected" ]]; then
  echo "FAIL: vendor repo trusted/pinned/held - could not read expected version from bootstrap metadata"
  fail=1
else
  installed=$(dpkg-query -W -f='${Version}' telemetry-agent 2>/dev/null || echo "")
  status=$(dpkg-query -W -f='${Status}' telemetry-agent 2>/dev/null || echo "")

  if [[ "$installed" != "$expected" || "$status" != "install ok installed" ]]; then
    echo "FAIL: vendor repo trusted/pinned/held - telemetry-agent version is '$installed' (status '$status'), expected exactly '$expected' installed"
    fail=1
  fi
fi

# --- 3. Held ---
if ! apt-mark showhold 2>/dev/null | grep -qx telemetry-agent; then
  echo "FAIL: vendor repo trusted/pinned/held - 'telemetry-agent' not present in apt-mark showhold"
  fail=1
fi

if [[ "$fail" -ne 0 ]]; then
  exit 1
fi

echo "PASS: vendor repo is trusted via a dedicated signed-by keyring, telemetry-agent is pinned at $expected and held"
exit 0
