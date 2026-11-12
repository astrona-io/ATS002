#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Bootstrap: ensures the cron daemon is installed and running before the
# lab's per-user crontab tasks depend on it.

set -eu

sudo systemctl enable --now cron
ASTRONA_STUDENT_SCRIPT
