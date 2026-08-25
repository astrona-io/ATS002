#!/usr/bin/env bash
# Bootstrap: creates and starts data-ingest.service, a long-running unit
# with an explicit, low TasksMax= cgroup cap -- simulating the systemd-side
# ceiling the scenario asks the student to raise. It runs as the dataproc
# user created in 02-dataproc-user.sh, so that script must run first.

set -eu

sudo mkdir -p /opt/lab-scripts

sudo tee /opt/lab-scripts/data-ingest.py > /dev/null <<'EOF'
import time
time.sleep(10 ** 8)
EOF

sudo tee /etc/systemd/system/data-ingest.service > /dev/null <<'EOF'
[Unit]
Description=data-ingest lab workload
After=network.target

[Service]
ExecStart=/usr/bin/python3 /opt/lab-scripts/data-ingest.py
User=dataproc
TasksMax=50

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now data-ingest.service
