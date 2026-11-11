#!/usr/bin/env bash
set -euo pipefail
sudo docker build -t status-page:1.0 /opt/course/25/build
sudo docker volume create status-data
sudo docker network create status-net
sudo docker run -d --name status-web --network status-net -v status-data:/data status-page:1.0
