#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Bootstrap: creates the crew account and starts three background crew
# processes: a CPU burner, a script that ignores SIGTERM, and a sleeper.
set -eu

if ! id crew >/dev/null 2>&1; then
  sudo useradd -m -s /bin/bash crew
fi

sudo install -d -m 0755 /opt/crew /opt/course/7

sudo tee /opt/crew/cpuburn.sh >/dev/null <<'EOF'
#!/bin/bash
# Uses one whole CPU until it is stopped.
while :; do :; done
EOF

sudo tee /opt/crew/stubborn.sh >/dev/null <<'EOF'
#!/bin/bash
# Ignores SIGTERM on purpose. Only SIGKILL ends it.
trap "" TERM
while :; do sleep 1; done
EOF

sudo tee /opt/crew/crew-sleeper.sh >/dev/null <<'EOF'
#!/bin/bash
# A quiet crew member that waits.
while :; do sleep 60; done
EOF

sudo chmod 0755 /opt/crew/cpuburn.sh /opt/crew/stubborn.sh /opt/crew/crew-sleeper.sh

for name in cpuburn stubborn crew-sleeper; do
  sudo systemctl stop "crew-${name}.service" 2>/dev/null || true
  sudo systemctl reset-failed "crew-${name}.service" 2>/dev/null || true
  sudo systemd-run --quiet --unit="crew-${name}" --uid=crew "/opt/crew/${name}.sh"
done
ASTRONA_STUDENT_SCRIPT
