#!/usr/bin/env bash
set -euo pipefail
sudo mkdir -p /etc/sysctl.d
sudo tee /etc/sysctl.d/99-pid-max.conf >/dev/null <<'REFERENCE_FILE'
kernel.pid_max=4194304
REFERENCE_FILE
sudo sysctl --system
sudo mkdir -p /etc/security/limits.d
sudo tee /etc/security/limits.d/50-dataproc.conf >/dev/null <<'REFERENCE_FILE'
dataproc soft nproc 32768
dataproc hard nproc 65536
REFERENCE_FILE
sudo mkdir -p /etc/systemd/system/data-ingest.service.d
sudo tee /etc/systemd/system/data-ingest.service.d/override.conf >/dev/null <<'REFERENCE_FILE'
[Service]
TasksMax=infinity
REFERENCE_FILE
sudo systemctl daemon-reload
sudo systemctl restart data-ingest
