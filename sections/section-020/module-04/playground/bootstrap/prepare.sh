#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# OS prep for PLAYGROUND: One-Shot And Missed Jobs.
#
# Installs at and anacron, starts atd, creates the user ops-monitor and
# installs the script archive-logs.sh. There is no task and no grading.
set -eu

sudo DEBIAN_FRONTEND=noninteractive apt-get update -qq
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq at anacron cron

sudo systemctl enable --now atd

if ! id ops-monitor >/dev/null 2>&1; then
  sudo useradd -m -s /bin/bash ops-monitor
fi

sudo tee /usr/local/sbin/archive-logs.sh >/dev/null <<'EOF'
#!/bin/bash
# Stand-in log archiver: writes one line with the time to its log file.
echo "archive-logs ran at $(date -Is)" >> /var/log/archive-logs.log
EOF
sudo chmod 0755 /usr/local/sbin/archive-logs.sh

# Start clean: no allow file, so cron.deny alone decides.
sudo rm -f /etc/cron.allow /etc/cron.deny

echo "[playground] at-anacron-bay: ready. Try: echo date | at now + 2 minutes"
ASTRONA_STUDENT_SCRIPT
