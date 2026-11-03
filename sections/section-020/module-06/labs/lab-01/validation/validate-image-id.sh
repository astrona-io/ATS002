#!/usr/bin/env bash
# Confirms /home/pilot/relay-image-id.txt holds the image ID of the container relay.

set -u

file=/home/pilot/relay-image-id.txt
if [[ ! -s "$file" ]]; then
  echo "FAIL: $file is missing or empty"
  exit 1
fi

pilot_uid="$(id -u pilot 2>/dev/null || true)"
run_as_pilot() {
  if [[ -d "/run/user/$pilot_uid" ]]; then
    sudo -u pilot env XDG_RUNTIME_DIR="/run/user/$pilot_uid" HOME=/home/pilot "$@"
  else
    sudo -u pilot env HOME=/home/pilot "$@"
  fi
}

expected="$(run_as_pilot podman inspect --format '{{ .Image }}' relay 2>/dev/null || true)"
if [[ -z "$expected" ]]; then
  echo "FAIL: cannot read the image ID of the container relay"
  exit 1
fi

saved="$(tr -d '[:space:]' < "$file")"
if [[ "$saved" != "$expected" && "$expected" != "$saved"* ]]; then
  echo "FAIL: $file holds '$saved', expected the image ID '$expected'"
  exit 1
fi

echo "PASS: $file holds the image ID of relay"
exit 0
