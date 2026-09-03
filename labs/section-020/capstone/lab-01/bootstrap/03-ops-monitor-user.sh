#!/usr/bin/env bash
# Bootstrap: creates the ops-monitor service account that will own the
# recovery cron job, and gives it docker-group access so a cron-invoked
# script can run docker commands without needing an interactive sudo
# password prompt.

set -eu

if ! id ops-monitor >/dev/null 2>&1; then
  sudo useradd -m -s /bin/bash ops-monitor
fi

sudo usermod -aG docker ops-monitor

if ! command -v crontab >/dev/null 2>&1; then
  sudo apt-get update -y
  sudo apt-get install -y cron
fi

sudo systemctl enable --now cron
