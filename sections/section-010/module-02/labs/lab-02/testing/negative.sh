#!/usr/bin/env bash
set -euo pipefail
sudo mkdir -p /etc/security/limits.d
sudo tee /etc/security/limits.d/50-dataproc.conf >/dev/null <<'REFERENCE_FILE'
dataproc soft nproc 256
dataproc hard nproc 256
REFERENCE_FILE
