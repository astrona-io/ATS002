#!/usr/bin/env bash
set -euo pipefail
sudo mkdir -p /etc/systemd/system
sudo tee /etc/systemd/system/report.service >/dev/null <<'REFERENCE_FILE'
[Service]
Type=oneshot
ExecStart=/usr/local/sbin/report.sh
REFERENCE_FILE
sudo mkdir -p /etc/systemd/system
sudo tee /etc/systemd/system/report.timer >/dev/null <<'REFERENCE_FILE'
[Timer]
OnCalendar=Mon,Thu 11:15
Persistent=true
[Install]
WantedBy=timers.target
REFERENCE_FILE
sudo mkdir -p /etc/systemd/system
sudo tee /etc/systemd/system/dbclean.service >/dev/null <<'REFERENCE_FILE'
[Service]
Type=oneshot
ExecStart=/usr/local/sbin/dbclean.sh
REFERENCE_FILE
sudo mkdir -p /etc/systemd/system
sudo tee /etc/systemd/system/dbclean.timer >/dev/null <<'REFERENCE_FILE'
[Timer]
OnCalendar=*-*-* 0/6:00:00
Persistent=true
[Install]
WantedBy=timers.target
REFERENCE_FILE
sudo systemctl daemon-reload
sudo systemctl enable --now report.timer dbclean.timer
sudo rm /etc/cron.d/dbclean
