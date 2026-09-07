#!/usr/bin/env bash
# OS prep for the systemd service-debugging playground. Installs apache2,
# then parks a tiny listener on TCP 80 via its own systemd unit so that
# `systemctl start apache2` fails with (98)Address already in use — a
# real, reproducible failed unit with a genuine journal trail. No task,
# no grading.
set -eu

export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -qq
sudo apt-get install -y -qq apache2 socat iproute2

# Make sure apache2 is not the thing on :80.
sudo systemctl disable --now apache2 || true

# A minimal unit that just holds port 80 open forever.
sudo tee /etc/systemd/system/port80-hog.service > /dev/null << 'UNIT'
[Unit]
Description=Playground: holds TCP 80 so apache2 cannot bind

[Service]
ExecStart=/usr/bin/socat -d TCP-LISTEN:80,reuseaddr,fork /dev/null
Restart=always

[Install]
WantedBy=multi-user.target
UNIT

sudo systemctl daemon-reload
sudo systemctl enable --now port80-hog.service
sleep 2

# Now try to start apache2 — it will fail. Leave it failed for diagnosis.
sudo systemctl start apache2 || true
sleep 2

echo "[playground] systemd-service-debugging: ready."
echo "[playground] apache2 is FAILED (port 80 is held by port80-hog.service)."
echo "[playground] try:  systemctl status apache2  ;  journalctl -xeu apache2  ;  sudo ss -ltnp 'sport = :80'"
