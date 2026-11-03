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

# Refresh the standard repository metadata baked into the base image, so
# search/info/what-provides all answer against current, real data. fail2ban,
# nginx, and iproute2 (which owns /usr/sbin/ip) all ship in openSUSE Leap
# 15.6's default oss repos, so no extra repository needs adding for this
# module's research-only scenario.
sudo docker exec zypperbox zypper --non-interactive --gpg-auto-import-keys refresh

# Seed a couple of genuinely-installed python3-* packages, so the filtered
# installed-only search the student runs in Step 4 has real, concrete
# results to find rather than an empty result set.
sudo docker exec zypperbox zypper --non-interactive install python3-base python3-pip

# Pre-create the directory the question asks the student to save each
# research finding into.
sudo docker exec zypperbox mkdir -p /root/answers
