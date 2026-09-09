#!/usr/bin/env bash
# Bootstrap: creates three long-running "collector" processes. Only
# collector2 periodically calls the forbidden kill() syscall (a harmless
# signal-0 self-probe every ~5 seconds -- a real kill() syscall, but not
# destructive) so an strace -e trace=kill session has a clear, deterministic
# syscall to catch within a short observation window.
#
# As in other labs, /proc/<PID>/exe and `ps -o comm` key off the *binary
# path actually passed to execve*, not argv or a shebang target -- so each
# service execs a *copy* of the python3 binary renamed to collectorN, with
# the actual Python source passed as a separate script argument. That copy
# IS the executed binary, so both `comm` and /proc/<PID>/exe resolve to the
# exact path the scenario expects.
#
# Deliberately no Restart=always: the task ends with the guilty process
# staying killed, which requires it to actually stay dead once terminated.

set -eu

PYTHON3_BIN="$(command -v python3)"

sudo mkdir -p /opt/lab-scripts
sudo mkdir -p /usr/local/bin

# --- collector1: innocent, just idles ---

sudo tee /opt/lab-scripts/collector1.py > /dev/null <<'EOF'
import time
while True:
    time.sleep(1)
EOF

sudo cp "$PYTHON3_BIN" /usr/local/bin/collector1
sudo chmod +x /usr/local/bin/collector1

sudo tee /etc/systemd/system/collector1.service > /dev/null <<'EOF'
[Unit]
Description=collector1 lab workload
After=network.target

[Service]
ExecStart=/usr/local/bin/collector1 /opt/lab-scripts/collector1.py
User=nobody

[Install]
WantedBy=multi-user.target
EOF

# --- collector2: guilty, calls kill() every ~5 seconds ---

sudo tee /opt/lab-scripts/collector2.py > /dev/null <<'EOF'
import os
import time

while True:
    time.sleep(5)
    os.kill(os.getpid(), 0)  # signal 0: harmless self-probe, but a real kill() syscall
EOF

sudo cp "$PYTHON3_BIN" /usr/local/bin/collector2
sudo chmod +x /usr/local/bin/collector2

sudo tee /etc/systemd/system/collector2.service > /dev/null <<'EOF'
[Unit]
Description=collector2 lab workload
After=network.target

[Service]
ExecStart=/usr/local/bin/collector2 /opt/lab-scripts/collector2.py
User=nobody

[Install]
WantedBy=multi-user.target
EOF

# --- collector3: innocent, just idles ---

sudo tee /opt/lab-scripts/collector3.py > /dev/null <<'EOF'
import time
while True:
    time.sleep(1)
EOF

sudo cp "$PYTHON3_BIN" /usr/local/bin/collector3
sudo chmod +x /usr/local/bin/collector3

sudo tee /etc/systemd/system/collector3.service > /dev/null <<'EOF'
[Unit]
Description=collector3 lab workload
After=network.target

[Service]
ExecStart=/usr/local/bin/collector3 /opt/lab-scripts/collector3.py
User=nobody

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now collector1.service
sudo systemctl enable --now collector2.service
sudo systemctl enable --now collector3.service
