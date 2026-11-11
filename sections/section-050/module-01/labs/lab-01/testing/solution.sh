#!/usr/bin/env bash
set -euo pipefail
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL http://127.0.0.1:8100/vendor-nginx-archive-keyring.asc | sudo gpg --dearmor --yes -o /etc/apt/keyrings/vendor-nginx.gpg
sudo mkdir -p /etc/apt/sources.list.d
sudo tee /etc/apt/sources.list.d/vendor-nginx.list >/dev/null <<'REFERENCE_FILE'
deb [signed-by=/etc/apt/keyrings/vendor-nginx.gpg] http://127.0.0.1:8100 vendor-nginx main
REFERENCE_FILE
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --allow-downgrades nginx=1.25.4-1~vendorfake1
sudo apt-mark hold nginx
