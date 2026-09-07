#!/usr/bin/env bash
# OS prep for the process-limits playground. Gives each of the three
# ceilings something concrete to look at. No task, no grading.
set -eu

# A workload user, so `ulimit -u` and /etc/security/limits.d have a subject.
if ! id -u dataproc >/dev/null 2>&1; then
  sudo useradd --create-home --shell /bin/bash dataproc
fi

# A demo service with a deliberately low TasksMax so `systemctl show`
# reveals a per-unit cgroup cap distinct from pid_max and ulimit.
sudo tee /etc/systemd/system/data-ingest.service > /dev/null << 'UNIT'
[Unit]
Description=Demo data-ingest worker (playground)

[Service]
Type=simple
ExecStart=/bin/sh -c 'while :; do sleep 30; done'
TasksMax=64
Restart=always

[Install]
WantedBy=multi-user.target
UNIT

sudo systemctl daemon-reload
sudo systemctl enable --now data-ingest.service

echo "[playground] process-limits-ceilings: ready."
echo "[playground] try:  sysctl -n kernel.pid_max  ;  ulimit -u  ;  systemctl show data-ingest.service -p TasksMax -p TasksCurrent"
