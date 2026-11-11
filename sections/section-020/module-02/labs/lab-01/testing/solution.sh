#!/usr/bin/env bash
set -euo pipefail
sudo docker stop frontend_v1
sudo mkdir -p /opt/course/11
sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' frontend_v2 | sudo tee /opt/course/11/ip-address
sudo docker inspect --format '{{ (index .Mounts 0).Destination }}' frontend_v2 | sudo tee /opt/course/11/mount-destination
sudo docker run -d --name frontend_v3 --memory=30m -p 1234:80 nginx:alpine
