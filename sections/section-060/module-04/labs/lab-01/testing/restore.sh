#!/usr/bin/env bash
set -euo pipefail
sudo docker exec -i rpmbox bash -se <<'CONTAINER_REFERENCE'
set -o pipefail
mv /tmp/search.saved /home/candidate/answers/search.txt
CONTAINER_REFERENCE
