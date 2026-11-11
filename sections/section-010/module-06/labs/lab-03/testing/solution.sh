#!/usr/bin/env bash
set -euo pipefail
sudo systemctl disable --now portsquatter
sudo systemctl daemon-reload
sudo systemctl enable --now webreport
sudo systemctl restart webreport
sleep 6
