#!/usr/bin/env bash
# Confirms at least one /etc/apt/sources.list.d/*.list file uses
# signed-by= pointing at a valid, dedicated keyring under
# /etc/apt/keyrings/, rather than relying on the deprecated global
# apt-key trusted keyring.

set -u

list_match=""
for f in /etc/apt/sources.list.d/*.list; do
  [[ -e "$f" ]] || continue
  if grep -qE 'signed-by=/etc/apt/keyrings/[^]]+\.gpg' "$f" 2>/dev/null; then
    list_match="$f"
    break
  fi
done

if [[ -z "$list_match" ]]; then
  echo "FAIL: modern trust configured - no /etc/apt/sources.list.d/*.list file uses a signed-by=/etc/apt/keyrings/*.gpg keyring"
  exit 1
fi

keyring_path=$(grep -oE 'signed-by=/etc/apt/keyrings/[^]]+\.gpg' "$list_match" | head -1 | cut -d= -f2)

if [[ ! -s "$keyring_path" ]]; then
  echo "FAIL: modern trust configured - referenced keyring '$keyring_path' does not exist or is empty"
  exit 1
fi

if ! gpg --show-keys "$keyring_path" >/dev/null 2>&1; then
  echo "FAIL: modern trust configured - '$keyring_path' is not a valid GPG keyring"
  exit 1
fi

echo "PASS: $list_match references a valid dedicated keyring at $keyring_path"
exit 0
