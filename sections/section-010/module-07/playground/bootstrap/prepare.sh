#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# OS prep for PLAYGROUND: Process Inspection And Control.
#
# Creates the user crew and starts three background processes (a CPU
# burner, a script that ignores SIGTERM, and a sleeper) as transient
# systemd services. Also installs a small helper, crew-restart, that starts
# all three again if the learner ends one. There is no task and no grading.
set -eu

if ! id crew >/dev/null 2>&1; then
  sudo useradd -m -s /bin/bash crew
fi

sudo install -d -m 0755 /opt/crew

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

sudo tee /usr/local/bin/crew-restart >/dev/null <<'EOF'
#!/usr/bin/env bash
# Stops and starts the three crew processes again, all as the user crew.
set -u
for name in cpuburn stubborn crew-sleeper; do
  systemctl stop "crew-${name}.service" 2>/dev/null || true
  systemctl reset-failed "crew-${name}.service" 2>/dev/null || true
  systemd-run --quiet --unit="crew-${name}" --uid=crew "/opt/crew/${name}.sh"
done
EOF
sudo chmod 0755 /usr/local/bin/crew-restart

sudo /usr/local/bin/crew-restart

echo "[playground] process-control-bay: ready. Try: ps -u crew -o pid,ni,pcpu,stat,comm"
ASTRONA_STUDENT_SCRIPT
