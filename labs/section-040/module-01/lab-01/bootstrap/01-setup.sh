#!/usr/bin/env bash
# Bootstrap: installs AppArmor userspace tooling, creates the "appservice"
# demo daemon and its relocated log directory (with correct DAC perms),
# and loads a deliberately too-strict AppArmor profile in enforce mode so
# the write to /srv/applogs is genuinely denied and reproducible.
set -eu

export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -y
sudo apt-get install -y apparmor apparmor-utils

# Dedicated, unprivileged system user for the service.
if ! id -u appservice >/dev/null 2>&1; then
  sudo useradd --system --no-create-home --shell /usr/sbin/nologin appservice
fi

# The "appservice" daemon: a minimal heartbeat logger standing in for any
# real long-running service. It writes one line every 5 seconds and keeps
# running (rather than crashing) even if a write attempt fails, so a fresh
# denial is always available to diagnose.
sudo tee /usr/sbin/appservice > /dev/null << 'SCRIPT'
#!/bin/bash
LOGFILE="/srv/applogs/app.log"
while true; do
  printf '%s appservice heartbeat pid=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$$" >> "$LOGFILE" || true
  sleep 5
done
SCRIPT
sudo chmod 755 /usr/sbin/appservice
sudo chown root:root /usr/sbin/appservice

# The service's original, no-longer-used default log directory (this is
# the only path the currently-installed profile below actually permits).
sudo mkdir -p /var/log/appservice
sudo chown appservice:appservice /var/log/appservice
sudo chmod 750 /var/log/appservice

# The service has ALREADY been reconfigured (by "a colleague") to log to
# this new location instead. DAC ownership/permissions here are already
# fully correct for the service's user -- only AppArmor stands in the way.
sudo mkdir -p /srv/applogs
sudo chown appservice:appservice /srv/applogs
sudo chmod 750 /srv/applogs

sudo tee /etc/systemd/system/appservice.service > /dev/null << 'UNIT'
[Unit]
Description=AppService demo logging daemon
After=network.target

[Service]
Type=simple
User=appservice
Group=appservice
ExecStart=/usr/sbin/appservice
Restart=on-failure
RestartSec=2

[Install]
WantedBy=multi-user.target
UNIT

# Real Ubuntu convention: packaged profiles include an optional local
# override file under /etc/apparmor.d/local/ so an admin can extend policy
# without editing the shipped profile directly. Ship it empty.
sudo mkdir -p /etc/apparmor.d/local
sudo tee /etc/apparmor.d/local/usr.sbin.appservice > /dev/null << 'LOCAL'
# Site-specific additions and overrides for usr.sbin.appservice go here.
LOCAL

# Deliberately too-strict profile: it only knows about the service's OLD
# log location, /var/log/appservice/. There is no rule at all for the new
# /srv/applogs path, so any write there is denied even though DAC
# permissions on /srv/applogs are already correct.
sudo tee /etc/apparmor.d/usr.sbin.appservice > /dev/null << 'PROFILE'
#include <tunables/global>

/usr/sbin/appservice {
  #include <abstractions/base>
  #include <abstractions/bash>

  /usr/sbin/appservice r,
  /bin/bash ix,
  /usr/bin/date rix,
  /usr/bin/sleep rix,

  /var/log/appservice/ r,
  /var/log/appservice/*.log rw,

  #include if exists <local/usr.sbin.appservice>
}
PROFILE

# Load the profile in enforce mode so the denial is genuinely active.
sudo apparmor_parser -r /etc/apparmor.d/usr.sbin.appservice

sudo systemctl daemon-reload
sudo systemctl enable --now appservice

# Give the service a few cycles to attempt (and fail) its writes, so a
# real DENIED audit entry already exists for the student to find.
sleep 6
