#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# OS prep for PLAYGROUND - Podman And Rootless Containers
#
# Runs once when the environment comes up. Environment preparation only:
# install Podman and the helpers rootless containers need, create the user
# pilot and let pilot's services keep running without a login. There is no
# task and no grading.
set -euo pipefail

echo "[playground] podman-rootless-bay: installing Podman ..."
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -qq
sudo apt-get install -y -qq podman uidmap slirp4netns systemd-container

if ! id pilot >/dev/null 2>&1; then
  sudo useradd -m -s /bin/bash pilot
fi

# Rootless containers need a range of subordinate user and group IDs.
if ! grep -q '^pilot:' /etc/subuid; then
  sudo usermod --add-subuids 100000-165535 pilot
fi
if ! grep -q '^pilot:' /etc/subgid; then
  sudo usermod --add-subgids 100000-165535 pilot
fi

sudo loginctl enable-linger pilot

echo "[playground] podman-rootless-bay: ready."
ASTRONA_STUDENT_SCRIPT
