#!/usr/bin/env bash
# Bootstrap: seeds the decommissioned billing_v1 container the capstone
# describes. It is running and bound to host port 9090 — the exact port
# the replacement container needs — so it must be fully retired (stopped
# AND removed) before frontend_v2's port mapping can be created.

set -eu

sudo docker pull nginx:alpine

sudo docker rm -f billing_v1 billing_v2 >/dev/null 2>&1 || true

sudo docker run -d --name billing_v1 -p 9090:80 nginx:alpine
