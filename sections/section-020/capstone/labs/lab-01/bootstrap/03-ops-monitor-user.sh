#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Bootstrap: creates the ops-monitor service account that will own the
# recovery cron job, and gives it docker-group access so a cron-invoked
# script can run docker commands without needing an interactive sudo
# password prompt.

set -eu

if ! id ops-monitor >/dev/null 2>&1; then
  sudo useradd -m -s /bin/bash ops-monitor
fi

sudo usermod -aG docker ops-monitor

sudo systemctl enable --now cron
ASTRONA_STUDENT_SCRIPT
