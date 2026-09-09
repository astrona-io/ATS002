#!/usr/bin/env bash
set -eu

sudo systemctl enable --now docker

# Give the student user docker-group access for convenience during the lab.
if id "student" >/dev/null 2>&1; then
  sudo usermod -aG docker student || true
fi

# Wait for the docker daemon to actually be ready before anything else runs.
for _ in $(seq 1 30); do
  if sudo docker info >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

sudo docker info >/dev/null 2>&1
