#!/usr/bin/env bash
# OS prep for PLAYGROUND - Container Images, Volumes And Networks
#
# Runs once when the environment comes up. Environment preparation only:
# start Docker, pull two small images and stage a folder with one web page
# to build an image from. There is no task and no grading.
set -euo pipefail

echo "[playground] container-build-bay: starting Docker ..."
sudo systemctl enable --now docker

for _ in $(seq 1 30); do
  if sudo docker info >/dev/null 2>&1; then
    break
  fi
  sleep 2
done
sudo docker info >/dev/null 2>&1

if id "student" >/dev/null 2>&1; then
  sudo usermod -aG docker student || true
fi

echo "[playground] pulling nginx:alpine and alpine ..."
sudo docker pull nginx:alpine
sudo docker pull alpine

echo "[playground] staging /opt/demo/status-page ..."
sudo mkdir -p /opt/demo/status-page
sudo tee /opt/demo/status-page/index.html >/dev/null <<'HTML'
<h1>Status page</h1>
<p>All systems go.</p>
HTML
sudo chmod 0777 /opt/demo/status-page
sudo chmod 0644 /opt/demo/status-page/index.html

echo "[playground] container-build-bay: ready."
