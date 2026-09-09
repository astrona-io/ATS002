#!/usr/bin/env bash
# Bootstrap: ensures the cron daemon is installed and running before the
# lab's per-user crontab tasks depend on it.

set -eu

sudo systemctl enable --now cron
