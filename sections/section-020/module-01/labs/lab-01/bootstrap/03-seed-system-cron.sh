#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Bootstrap: seeds the pre-existing system-wide cronjob the scenario
# describes — a job that runs as asset-manager once a day at 8:30pm,
# defined in a system-wide drop-in instead of asset-manager's own crontab.
# This is the job the student must migrate.

set -eu

sudo tee /etc/cron.d/asset-cleanup > /dev/null <<'EOF'
30 20 * * * asset-manager /home/asset-manager/nightly-sync.sh
EOF

sudo chmod 644 /etc/cron.d/asset-cleanup
ASTRONA_STUDENT_SCRIPT
