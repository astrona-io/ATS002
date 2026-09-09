#!/usr/bin/env bash
# Diagnosis variant of the process-limits lab: of the three independent
# ceilings, only ONE is actually clamping the dataproc workload.
#
#   kernel.pid_max          -> raised to 4194304, live AND via a drop-in
#                              (already generous, NOT the problem)
#   data-ingest.service     -> TasksMax=infinity
#                              (already uncapped, NOT the problem)
#   dataproc RLIMIT_NPROC   -> forced to 256 via a limits.d baseline
#                              (THIS is the only real ceiling)
#
# The student must run `sysctl -n kernel.pid_max`, `ulimit -u` (as
# dataproc), and `systemctl show data-ingest.service -p TasksMax`, notice
# that two of the three are already fine, and raise ONLY ulimit -u
# (persistently, via /etc/security/limits.d/). Reflexively bumping all
# three -- the lab-01 habit -- is exactly what this variant is here to
# break.
set -eu

# --- ceiling 1: pid_max, already generous ---
sudo sysctl -w kernel.pid_max=4194304 > /dev/null
echo "kernel.pid_max = 4194304" | sudo tee /etc/sysctl.d/00-pid-max-baseline.conf > /dev/null
sudo sysctl --system > /dev/null

# --- ceiling 2 subject: the dataproc user ---
if ! id dataproc >/dev/null 2>&1; then
  sudo useradd -m -s /bin/bash dataproc
fi

# --- ceiling 2: RLIMIT_NPROC, forced LOW -- the actual clamp ---
sudo tee /etc/security/limits.d/00-dataproc-baseline.conf > /dev/null <<'EOF'
dataproc soft nproc 256
dataproc hard nproc 256
EOF

# --- ceiling 3: the unit's cgroup cap, already uncapped ---
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
TasksMax=infinity

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now data-ingest.service
