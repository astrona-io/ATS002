#!/usr/bin/env bash
set -euo pipefail
sudo docker exec -i rpmbox bash -se <<'CONTAINER_REFERENCE'
set -o pipefail
rpm -e metrics-shipper
CONTAINER_REFERENCE
