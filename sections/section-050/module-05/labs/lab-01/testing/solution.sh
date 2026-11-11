#!/usr/bin/env bash
set -euo pipefail
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential git cmake pkg-config
dpkg-query -W -f='${binary:Package}
' 'php8.1-*' | xargs sudo apt-mark hold
