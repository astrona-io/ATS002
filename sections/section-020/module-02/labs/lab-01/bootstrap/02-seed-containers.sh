#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Bootstrap: seeds the two running containers the scenario describes.
# frontend_v1 exists only to be stopped. frontend_v2 carries a real bridge
# IP address and exactly one bind-mounted volume, so its metadata has
# something concrete for docker inspect --format to extract.

set -eu

sudo docker pull nginx:alpine

sudo docker rm -f frontend_v1 frontend_v2 >/dev/null 2>&1 || true

sudo docker run -d --name frontend_v1 nginx:alpine

sudo mkdir -p /opt/frontend_v2/html
sudo docker run -d \
  --name frontend_v2 \
  -v /opt/frontend_v2/html:/usr/share/nginx/html \
  nginx:alpine
ASTRONA_STUDENT_SCRIPT
