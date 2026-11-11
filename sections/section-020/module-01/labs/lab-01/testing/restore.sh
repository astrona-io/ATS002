#!/usr/bin/env bash
set -euo pipefail
sudo crontab -u asset-manager - <<'CRON'
30 20 * * * /home/asset-manager/nightly-sync.sh
15 11 * * MON,THU bash /home/asset-manager/clean.sh
CRON
