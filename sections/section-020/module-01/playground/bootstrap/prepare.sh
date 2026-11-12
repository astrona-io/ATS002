#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# OS prep for PLAYGROUND -- Per-User Cron Job Scheduling
#
# Runs once when the environment comes up. Environment preparation only:
# make sure cron runs, create two service accounts with the scripts their
# jobs would run, and seed two system-wide cron files to practise on.
# There is no task and no grading.
set -euo pipefail

echo "[playground] cron-schedule-bay: preparing cron ..."
if ! command -v crontab >/dev/null 2>&1; then
  export DEBIAN_FRONTEND=noninteractive
  sudo apt-get update -qq
  sudo apt-get install -y -qq cron
fi
sudo systemctl enable --now cron

for account in archivist asset-manager; do
  if ! id "$account" >/dev/null 2>&1; then
    sudo useradd -m -s /bin/bash "$account"
  fi
done

sudo tee /home/archivist/archive-logs.sh >/dev/null <<'EOF'
#!/usr/bin/env bash
# Placeholder nightly log archive job for archivist.
echo "$(date -Iseconds) archive-logs ran" >> /home/archivist/archive-logs.log
EOF

sudo tee /home/asset-manager/nightly-sync.sh >/dev/null <<'EOF'
#!/usr/bin/env bash
# Placeholder nightly data sync job for asset-manager.
echo "$(date -Iseconds) nightly-sync ran" >> /home/asset-manager/nightly-sync.log
EOF

sudo tee /home/asset-manager/clean.sh >/dev/null <<'EOF'
#!/usr/bin/env bash
# Placeholder cleanup job for asset-manager.
echo "$(date -Iseconds) clean ran" >> /home/asset-manager/clean.log
EOF

sudo chmod 755 /home/archivist/archive-logs.sh /home/asset-manager/nightly-sync.sh /home/asset-manager/clean.sh
sudo chown archivist:archivist /home/archivist/archive-logs.sh
sudo chown asset-manager:asset-manager /home/asset-manager/nightly-sync.sh /home/asset-manager/clean.sh

# System-wide cron files have six fields: the sixth is the user name.
echo '0 22 * * * archivist /home/archivist/archive-logs.sh' | sudo tee /etc/cron.d/log-archive >/dev/null
echo '30 20 * * * asset-manager /home/asset-manager/nightly-sync.sh' | sudo tee /etc/cron.d/asset-cleanup >/dev/null
sudo chmod 644 /etc/cron.d/log-archive /etc/cron.d/asset-cleanup

echo "[playground] cron-schedule-bay: ready."
ASTRONA_STUDENT_SCRIPT
