#!/usr/bin/env bash
set -euo pipefail
sudo mkdir -p /etc/apt/preferences.d
sudo tee /etc/apt/preferences.d/pin-curl-release >/dev/null <<'REFERENCE_FILE'
Package: curl
Pin: release a=noble
Pin-Priority: 1001
REFERENCE_FILE
sudo apt-get update
