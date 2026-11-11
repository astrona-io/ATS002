#!/usr/bin/env bash
set -euo pipefail
sudo docker exec -i rpmbox bash -se <<'CONTAINER_REFERENCE'
set -o pipefail
mv /home/candidate/answers/search.txt /tmp/search.saved
CONTAINER_REFERENCE
