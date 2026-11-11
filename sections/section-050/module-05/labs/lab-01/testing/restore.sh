#!/usr/bin/env bash
set -euo pipefail
dpkg-query -W -f='${binary:Package}\n' 'php8.1-*' | xargs sudo apt-mark hold
