#!/usr/bin/env bash
set -euo pipefail
for tool in docker; do command -v "$tool"; done
sudo docker exec rpmbox rpm --version
