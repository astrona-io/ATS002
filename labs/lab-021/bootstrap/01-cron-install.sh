#!/usr/bin/env bash
# Bootstrap: ensures the cron daemon is installed and running before the
# lab's per-user crontab tasks depend on it.

set -eu

if ! command -v crontab >/dev/null 2>&1; then
  sudo apt-get update -y
  sudo apt-get install -y cron
fi

sudo systemctl enable --now cron
