#!/usr/bin/env bash
set -euo pipefail
sudo atq | awk '{print $1}' | xargs -r sudo atrm
