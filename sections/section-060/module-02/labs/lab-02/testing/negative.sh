#!/usr/bin/env bash
set -euo pipefail
sudo docker exec -i rpmbox bash -se <<'CONTAINER_REFERENCE'
set -o pipefail
dep=$(sed -n '2p' /root/.lab066-broken)
test -n "$dep"
rpm -e --nodeps "$dep"
CONTAINER_REFERENCE
