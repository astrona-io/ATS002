#!/usr/bin/env bash
set -euo pipefail
printf '%s
' /usr/local/sbin/archive-logs.sh | sudo at 03:00 tomorrow
printf '%s
' '7 10 weekly-archive /usr/local/sbin/archive-logs.sh' | sudo tee -a /etc/anacrontab
printf '%s
' ops-monitor | sudo tee -a /etc/cron.deny
