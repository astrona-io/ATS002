#!/usr/bin/env bash
# OS prep for the strace playground. Installs strace and starts three
# long-running "collector" processes so pgrep/strace/readlink have real
# subjects. One of them (collector2) periodically makes a kill() syscall,
# so `strace -e trace=kill` actually catches something. No task, no grading.
set -eu

export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -qq
sudo apt-get install -y -qq strace procps

sudo tee /usr/local/bin/collector1 > /dev/null << 'EOF'
#!/bin/bash
while :; do sleep 5; done
EOF

# collector2 sends itself SIGCONT every ~10s -> a real kill() syscall to trace.
sudo tee /usr/local/bin/collector2 > /dev/null << 'EOF'
#!/bin/bash
while :; do sleep 10; kill -CONT $$; done
EOF

sudo tee /usr/local/bin/collector3 > /dev/null << 'EOF'
#!/bin/bash
while :; do sleep 7; done
EOF

sudo chmod 755 /usr/local/bin/collector1 /usr/local/bin/collector2 /usr/local/bin/collector3

for n in 1 2 3; do
  sudo tee "/etc/systemd/system/collector${n}.service" > /dev/null << EOF
[Unit]
Description=Demo collector ${n} (playground)
[Service]
ExecStart=/usr/local/bin/collector${n}
Restart=always
[Install]
WantedBy=multi-user.target
EOF
done

sudo systemctl daemon-reload
sudo systemctl enable --now collector1.service collector2.service collector3.service

echo "[playground] strace-process-forensics: ready."
echo "[playground] try:  pgrep -a -f collector  ;  sudo strace -p \$(pgrep -f collector2) -e trace=kill,clock_nanosleep"
