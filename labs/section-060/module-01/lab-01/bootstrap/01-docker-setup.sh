#!/usr/bin/env bash
# Installs Docker on the Ubuntu host and starts a long-lived, privileged
# Rocky Linux 9 container ("rpmbox") that provides a REAL rpm environment
# for this lab. This repo's only VM base image is Ubuntu 24.04 -- there is
# no Rocky/RHEL VM available, so this is how we give students genuine
# rpm/dnf tooling against a real RPM database rather than a faked one. See
# module-01/course.md and this lab's README.md for the full explanation.

set -eu

echo "Enabling Docker..."
sudo systemctl enable --now docker

echo "Waiting for the Docker daemon to be ready..."
for i in $(seq 1 30); do
  if sudo docker info >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

echo "Pulling rockylinux:9..."
sudo docker pull rockylinux:9

echo "Starting the long-lived rpmbox container..."
sudo docker rm -f rpmbox >/dev/null 2>&1 || true
sudo docker run -d --name rpmbox --privileged rockylinux:9 sleep infinity

echo "Waiting for dnf inside rpmbox to be responsive..."
for i in $(seq 1 30); do
  if sudo docker exec rpmbox dnf --version >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

echo "Refreshing dnf repo metadata inside rpmbox..."
sudo docker exec rpmbox dnf -y makecache

echo "rpmbox is ready."
