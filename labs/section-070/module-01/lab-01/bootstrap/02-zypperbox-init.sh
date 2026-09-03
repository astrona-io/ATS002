#!/usr/bin/env bash
set -eu

# Start the long-lived openSUSE Leap 15.6 sandbox container, if not already running.
if ! sudo docker ps -a --format '{{.Names}}' | grep -qx zypperbox; then
  sudo docker run -d --name zypperbox --privileged opensuse/leap:15.6 sleep infinity
fi

# Wait for the container to actually be up before exec'ing into it.
for _ in $(seq 1 30); do
  if sudo docker ps --format '{{.Names}}' | grep -qx zypperbox; then
    break
  fi
  sleep 2
done
sudo docker ps --format '{{.Names}}' | grep -qx zypperbox

# Refresh the standard repository metadata baked into the base image.
sudo docker exec zypperbox zypper --non-interactive --gpg-auto-import-keys refresh

# telnet-server (the package providing the telnetd daemon) is not part of
# openSUSE Leap's default oss repo; it lives in the community
# "network:utilities" OBS project. Add that repository so the package is
# genuinely installable, matching real-world openSUSE administration.
if ! sudo docker exec zypperbox zypper lr | grep -qi network-utilities; then
  sudo docker exec zypperbox zypper --non-interactive addrepo --refresh \
    "https://download.opensuse.org/repositories/network:/utilities/15.6/" \
    network-utilities
fi
sudo docker exec zypperbox zypper --non-interactive --gpg-auto-import-keys refresh

# Seed the required starting state: telnet-server installed, fail2ban absent.
sudo docker exec zypperbox zypper --non-interactive install telnet-server
sudo docker exec zypperbox zypper --non-interactive remove fail2ban || true
