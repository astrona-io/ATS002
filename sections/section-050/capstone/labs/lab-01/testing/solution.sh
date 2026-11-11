#!/usr/bin/env bash
set -euo pipefail
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL http://127.0.0.1:8200/app-tools-archive-keyring.asc | sudo gpg --dearmor --yes -o /etc/apt/keyrings/app-tools.gpg
sudo mkdir -p /etc/apt/sources.list.d
sudo tee /etc/apt/sources.list.d/app-tools.list >/dev/null <<'REFERENCE_FILE'
deb [signed-by=/etc/apt/keyrings/app-tools.gpg] http://127.0.0.1:8200 app-tools main
REFERENCE_FILE
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --allow-downgrades telemetry-agent=2.4.0-1~apptoolsfake1
sudo apt-mark hold telemetry-agent
sudo dpkg --configure -a
sudo DEBIAN_FRONTEND=noninteractive apt-get -f install -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y curl git jq
dpkg-query -W -f='${binary:Package}
' 'obsagent-*' | xargs sudo apt-mark hold
apt-cache policy redis-server | sudo tee /opt/course/onboarding/redis-candidate.txt
