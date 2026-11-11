#!/usr/bin/env bash
set -euo pipefail
sudo docker exec -i rpmbox bash -se <<'CONTAINER_REFERENCE'
set -o pipefail
read -r victim dep < /root/.lab066-broken
rpm -e --nodeps "$dep"
CONTAINER_REFERENCE
