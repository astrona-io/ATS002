#!/usr/bin/env bash
set -euo pipefail
sudo docker exec rpmbox rpm -e --justdb --nodeps tree
