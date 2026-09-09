#!/usr/bin/env bash
# Diagnosis variant: of the three independent process ceilings, only the
# systemd unit's own TasksMax= cgroup cap is clamping.
#
#   kernel.pid_max          -> 4194304, live + drop-in   (NOT the problem)
#   dataproc RLIMIT_NPROC   -> 65536 via limits.d         (NOT the problem)
#   data-ingest.service     -> TasksMax=64                (THIS is the clamp)
#
# The student inspects all three, sees that two are already generous, and
# raises ONLY the unit override -- then applies it to the running unit with
# `daemon-reload` + `restart`. A drop-in raising pid_max, or a limits.d file
# raising ulimit -u, is a misdiagnosis here.
set -eu

# --- ceiling 1: pid_max, already generous ---
sudo sysctl -w kernel.pid_max=4194304 > /dev/null
echo "kernel.pid_max = 4194304" | sudo tee /etc/sysctl.d/00-pid-max-baseline.conf > /dev/null
sudo sysctl --system > /dev/null

# --- ceiling 2 subject + already-generous limit ---
if ! id dataproc >/dev/null 2>&1; then
  sudo useradd -m -s /bin/bash dataproc
fi
sudo tee /etc/security/limits.d/00-dataproc-baseline.conf > /dev/null <<'EOF'
dataproc soft nproc 65536
dataproc hard nproc 65536
EOF

# --- ceiling 3: the unit's cgroup cap, forced LOW -- the actual clamp ---
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
TasksMax=64

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now data-ingest.service
