#!/usr/bin/env bash
# Installs Docker on the Ubuntu host and starts the long-lived, privileged
# Rocky Linux 9 "rpmbox" container - the same pattern every section-060
# lab uses. See section-060/module-02/course.md for why.
set -eu

echo "Enabling Docker..."
sudo systemctl enable --now docker
for i in $(seq 1 30); do sudo docker info >/dev/null 2>&1 && break; sleep 1; done

echo "Pulling rockylinux:9..."
sudo docker pull rockylinux:9

echo "Starting rpmbox..."
sudo docker rm -f rpmbox >/dev/null 2>&1 || true
sudo docker run -d --name rpmbox --privileged rockylinux:9 sleep infinity

for i in $(seq 1 30); do sudo docker exec rpmbox dnf --version >/dev/null 2>&1 && break; sleep 1; done
sudo docker exec rpmbox dnf -y makecache
echo "rpmbox is ready."
