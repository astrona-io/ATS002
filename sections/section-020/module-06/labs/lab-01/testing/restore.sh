#!/usr/bin/env bash
set -euo pipefail
sudo loginctl enable-linger pilot
uid=$(id -u pilot)
sudo systemctl start user@$uid.service
sudo -iu pilot env XDG_RUNTIME_DIR=/run/user/$uid podman start relay
