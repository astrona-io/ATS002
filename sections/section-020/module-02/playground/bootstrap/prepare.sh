#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# OS prep for PLAYGROUND -- Docker Container Lifecycle
#
# Runs once when the environment comes up. Environment preparation only:
# make sure the Docker engine runs, pull nginx:alpine and dock one
# container with a bind mount for the lifecycle and inspect examples.
# There is no task and no grading.
set -euo pipefail

echo "[playground] docker-lifecycle-bay: starting Docker ..."
sudo systemctl enable --now docker

# Wait for the Docker daemon to accept commands.
for _ in $(seq 1 30); do
  if sudo docker info >/dev/null 2>&1; then
    break
  fi
  sleep 2
done
sudo docker info >/dev/null 2>&1

# Give the student user docker-group access for convenience.
if id "student" >/dev/null 2>&1; then
  sudo usermod -aG docker student || true
fi

echo "[playground] pulling nginx:alpine ..."
sudo docker pull nginx:alpine

sudo docker rm -f web_demo >/dev/null 2>&1 || true
sudo mkdir -p /opt/web_demo/html
sudo docker run -d \
  --name web_demo \
  -v /opt/web_demo/html:/usr/share/nginx/html \
  nginx:alpine

echo "[playground] docker-lifecycle-bay: ready."
ASTRONA_STUDENT_SCRIPT
