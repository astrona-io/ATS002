#!/usr/bin/env bash
set -euo pipefail
sudo chown -R metricsd:metricsd /var/lib/metricsd
sudo chmod 0750 /var/lib/metricsd
sudo systemctl daemon-reload
sudo systemctl enable --now metricsd
sudo systemctl restart metricsd
sleep 6
