#!/usr/bin/env bash
set -euo pipefail
sudo docker exec -i zypperbox bash -se <<'CONTAINER_REFERENCE'
set -o pipefail
mv /root/answers/01-research-search.txt /tmp/search.saved
CONTAINER_REFERENCE
