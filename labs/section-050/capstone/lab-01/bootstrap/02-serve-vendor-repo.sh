#!/usr/bin/env bash
# Bootstrap: serves /srv/vendor-repo over plain HTTP on 127.0.0.1:8200 as
# a persistent systemd unit, standing in for the vendor's real repository
# server. Runs for the lifetime of the VM so the student's `apt update`
# and `apt install` against it work throughout the lab.

set -eu

sudo tee /etc/systemd/system/vendor-repo-server.service >/dev/null <<'EOF'
[Unit]
Description=Local fake vendor APT repository (lab simulation)
After=network.target

[Service]
ExecStart=/usr/bin/python3 -m http.server 8200 --directory /srv/vendor-repo --bind 127.0.0.1
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now vendor-repo-server.service

# Give the service a moment to bind before the VM is handed to the student.
for _ in $(seq 1 10); do
  if curl -fsS "http://127.0.0.1:8200/app-tools-archive-keyring.asc" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done
