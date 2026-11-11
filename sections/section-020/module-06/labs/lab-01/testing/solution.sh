#!/usr/bin/env bash
set -euo pipefail
sudo loginctl enable-linger pilot
uid=$(id -u pilot)
sudo systemctl start user@$uid.service
sudo -iu pilot env XDG_RUNTIME_DIR=/run/user/$uid bash <<'PILOT'
set -eu
podman run -d --name relay -p 8090:80 docker.io/library/nginx:alpine
podman inspect --format '{{ .Image }}' relay > ~/relay-image-id.txt
PILOT
