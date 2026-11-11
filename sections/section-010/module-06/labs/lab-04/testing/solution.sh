#!/usr/bin/env bash
set -euo pipefail
sudo mkdir -p /etc/systemd/system/ingest-db.service.d
sudo tee /etc/systemd/system/ingest-db.service.d/override.conf >/dev/null <<'REFERENCE_FILE'
[Service]
ExecStart=
ExecStart=/usr/local/sbin/ingestdb
REFERENCE_FILE
sudo systemctl daemon-reload
sudo systemctl enable --now ingest-db
sudo systemctl reset-failed ingest
sudo systemctl daemon-reload
sudo systemctl enable --now ingest
sudo systemctl restart ingest
sleep 6
