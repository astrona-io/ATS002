#!/usr/bin/env bash
set -euo pipefail
sudo mkdir -p /etc/security/limits.d
sudo tee /etc/security/limits.d/50-dataproc.conf >/dev/null <<'REFERENCE_FILE'
dataproc soft nproc 32768
dataproc hard nproc 65536
REFERENCE_FILE
