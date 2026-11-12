#!/usr/bin/env bash
set -euo pipefail
sudo mkdir -p /etc/systemd/system/reportd.service.d
sudo tee /etc/systemd/system/reportd.service.d/override.conf >/dev/null <<'REFERENCE_FILE'
[Service]
ExecStart=
ExecStart=/usr/local/sbin/reportd
REFERENCE_FILE
sudo systemctl daemon-reload
sudo systemctl enable --now reportd
sudo systemctl restart reportd
sleep 6
