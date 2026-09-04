#!/usr/bin/env bash
# Bootstrap: starts telemetry-agent.service as a long-running unit that is
# genuinely, deliberately hung -- blocked forever inside the pause() libc/
# syscall, waiting on a signal that will never arrive. This gives an
# `strace -p PID` session a real, deterministic syscall to observe almost
# immediately (no "periodic" waiting window needed, unlike lab-015's
# kill()-every-5-seconds scenario), while still producing zero CPU usage
# and zero log output -- exactly the "hung, not just slow" signature the
# scenario describes.
#
# As in other labs, /proc/<PID>/exe and `ps -o comm` key off the *binary
# path actually passed to execve*, not argv or a shebang target -- so the
# service execs a *copy* of the python3 binary renamed to telemetry-agent,
# with the actual Python source passed as a separate script argument.
#
# Deliberately no Restart=always: once the student terminates it, it must
# stay dead for validation to pass.

set -eu

PYTHON3_BIN="$(command -v python3)"

sudo mkdir -p /opt/lab-scripts
sudo mkdir -p /usr/local/bin

sudo tee /opt/lab-scripts/telemetry-agent.py > /dev/null <<'EOF'
import ctypes
import ctypes.util

libc = ctypes.CDLL(ctypes.util.find_library("c"), use_errno=True)

# Block forever in the pause() syscall. pause() only returns when a signal
# is delivered, and immediately re-enters on the next loop iteration if the
# signal wasn't fatal -- a real, observable "stuck in pause()" signature
# under strace, and zero CPU usage between signals.
while True:
    libc.pause()
EOF

sudo cp "$PYTHON3_BIN" /usr/local/bin/telemetry-agent
sudo chmod +x /usr/local/bin/telemetry-agent

sudo tee /etc/systemd/system/telemetry-agent.service > /dev/null <<'EOF'
[Unit]
Description=telemetry-agent edge collector (lab workload)
After=network.target

[Service]
ExecStart=/usr/local/bin/telemetry-agent /opt/lab-scripts/telemetry-agent.py
User=nobody

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now telemetry-agent.service
