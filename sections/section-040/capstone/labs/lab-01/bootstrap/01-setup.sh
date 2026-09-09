#!/usr/bin/env bash
# Bootstrap: installs AppArmor userspace tooling and stands up two
# independent demo services, each confined by a deliberately too-strict
# AppArmor profile in enforce mode:
#
#   logshipper    -- reconfigured to WRITE logs to /srv/shiplogs instead
#                     of its original directory; profile only knows the
#                     old path, so the write is denied.
#
#   metrics-agent -- reconfigured to READ its credentials from
#                     /etc/metrics-agent/remote.conf instead of its
#                     original config file; profile only knows the old
#                     path, so the read is denied.
#
# DAC ownership/permissions are correct everywhere in both scenarios --
# only AppArmor stands in the way.
set -eu

sudo mkdir -p /etc/apparmor.d/local

##############################################################################
# Service 1: logshipper (write-path denial)
##############################################################################

if ! id -u logshipper >/dev/null 2>&1; then
  sudo useradd --system --no-create-home --shell /usr/sbin/nologin logshipper
fi

sudo tee /usr/sbin/logshipper > /dev/null << 'SCRIPT'
#!/bin/bash
LOGFILE="/srv/shiplogs/ship.log"
while true; do
  printf '%s logshipper heartbeat pid=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$$" >> "$LOGFILE" || true
  sleep 5
done
SCRIPT
sudo chmod 755 /usr/sbin/logshipper
sudo chown root:root /usr/sbin/logshipper

# Old, no-longer-used default log directory (the only path the
# currently-installed profile permits).
sudo mkdir -p /var/log/logshipper
sudo chown logshipper:logshipper /var/log/logshipper
sudo chmod 750 /var/log/logshipper

# New, already-reconfigured log directory. DAC is already correct here.
sudo mkdir -p /srv/shiplogs
sudo chown logshipper:logshipper /srv/shiplogs
sudo chmod 750 /srv/shiplogs

sudo tee /etc/systemd/system/logshipper.service > /dev/null << 'UNIT'
[Unit]
Description=Logshipper demo logging daemon
After=network.target

[Service]
Type=simple
User=logshipper
Group=logshipper
ExecStart=/usr/sbin/logshipper
Restart=on-failure
RestartSec=2

[Install]
WantedBy=multi-user.target
UNIT

sudo tee /etc/apparmor.d/local/usr.sbin.logshipper > /dev/null << 'LOCAL'
# Site-specific additions and overrides for usr.sbin.logshipper go here.
LOCAL

sudo tee /etc/apparmor.d/usr.sbin.logshipper > /dev/null << 'PROFILE'
#include <tunables/global>

/usr/sbin/logshipper {
  #include <abstractions/base>
  #include <abstractions/bash>

  /usr/sbin/logshipper r,
  /bin/bash ix,
  /usr/bin/date rix,
  /usr/bin/sleep rix,

  /var/log/logshipper/ r,
  /var/log/logshipper/*.log rw,

  #include if exists <local/usr.sbin.logshipper>
}
PROFILE

sudo apparmor_parser -r /etc/apparmor.d/usr.sbin.logshipper

##############################################################################
# Service 2: metrics-agent (read-path denial)
##############################################################################

if ! id -u metricsagent >/dev/null 2>&1; then
  sudo useradd --system --no-create-home --shell /usr/sbin/nologin metricsagent
fi

sudo tee /usr/sbin/metrics-agent > /dev/null << 'SCRIPT'
#!/bin/bash
CONF="/etc/metrics-agent/remote.conf"
STATUS="/var/lib/metrics-agent/status"
while true; do
  if content=$(cat "$CONF" 2>/dev/null); then
    printf '%s metrics-agent read ok: %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$content" >> "$STATUS" || true
  fi
  sleep 5
done
SCRIPT
sudo chmod 755 /usr/sbin/metrics-agent
sudo chown root:root /usr/sbin/metrics-agent

# Old, no-longer-used default config (the only path the currently-installed
# profile permits reading).
sudo mkdir -p /etc/metrics-agent
sudo tee /etc/metrics-agent/local.conf > /dev/null << 'EOF'
TOKEN=local-unused
EOF
sudo chown root:metricsagent /etc/metrics-agent/local.conf
sudo chmod 640 /etc/metrics-agent/local.conf

# New, already-reconfigured config file. DAC is already correct here --
# metricsagent's group can read it -- only AppArmor blocks it.
sudo tee /etc/metrics-agent/remote.conf > /dev/null << 'EOF'
TOKEN=remote-9f31ab
EOF
sudo chown root:metricsagent /etc/metrics-agent/remote.conf
sudo chmod 640 /etc/metrics-agent/remote.conf

# Status output directory -- this path is NOT part of the denial, it's
# already permitted, so the only variable under test is the config read.
sudo mkdir -p /var/lib/metrics-agent
sudo chown metricsagent:metricsagent /var/lib/metrics-agent
sudo chmod 750 /var/lib/metrics-agent
sudo touch /var/lib/metrics-agent/status
sudo chown metricsagent:metricsagent /var/lib/metrics-agent/status
sudo chmod 640 /var/lib/metrics-agent/status

sudo tee /etc/systemd/system/metrics-agent.service > /dev/null << 'UNIT'
[Unit]
Description=Metrics-agent demo daemon
After=network.target

[Service]
Type=simple
User=metricsagent
Group=metricsagent
ExecStart=/usr/sbin/metrics-agent
Restart=on-failure
RestartSec=2

[Install]
WantedBy=multi-user.target
UNIT

sudo tee /etc/apparmor.d/local/usr.sbin.metrics-agent > /dev/null << 'LOCAL'
# Site-specific additions and overrides for usr.sbin.metrics-agent go here.
LOCAL

sudo tee /etc/apparmor.d/usr.sbin.metrics-agent > /dev/null << 'PROFILE'
#include <tunables/global>

/usr/sbin/metrics-agent {
  #include <abstractions/base>
  #include <abstractions/bash>

  /usr/sbin/metrics-agent r,
  /bin/bash ix,
  /usr/bin/cat rix,
  /usr/bin/date rix,
  /usr/bin/sleep rix,

  /etc/metrics-agent/local.conf r,
  /var/lib/metrics-agent/ r,
  /var/lib/metrics-agent/status rw,

  #include if exists <local/usr.sbin.metrics-agent>
}
PROFILE

sudo apparmor_parser -r /etc/apparmor.d/usr.sbin.metrics-agent

##############################################################################
# Start both services now that both profiles are loaded in enforce mode.
##############################################################################

sudo systemctl daemon-reload
sudo systemctl enable --now logshipper
sudo systemctl enable --now metrics-agent

# Give both services a few cycles to attempt (and fail) their access, so
# real DENIED audit entries already exist for the student to find.
sleep 6
