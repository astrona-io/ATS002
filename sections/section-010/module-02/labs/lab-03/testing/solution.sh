#!/usr/bin/env bash
set -euo pipefail
sudo mkdir -p /etc/systemd/system/data-ingest.service.d
sudo tee /etc/systemd/system/data-ingest.service.d/override.conf >/dev/null <<'REFERENCE_FILE'
[Service]
TasksMax=infinity
REFERENCE_FILE
sudo systemctl daemon-reload
sudo systemctl restart data-ingest
