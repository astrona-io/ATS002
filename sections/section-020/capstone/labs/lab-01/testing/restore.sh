#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' '* * * * * bash /home/ops-monitor/watch-billing.sh' | sudo crontab -u ops-monitor -
