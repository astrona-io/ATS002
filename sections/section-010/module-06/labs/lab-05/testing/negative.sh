#!/usr/bin/env bash
set -euo pipefail
sudo mkdir -p /etc/systemd/journald.conf.d
sudo tee /etc/systemd/journald.conf.d/99-persistent.conf >/dev/null <<'REFERENCE_FILE'
[Journal]
Storage=volatile
SystemMaxUse=200M
REFERENCE_FILE
sudo systemctl restart systemd-journald
