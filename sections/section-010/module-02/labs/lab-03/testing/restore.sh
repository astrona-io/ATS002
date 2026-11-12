#!/usr/bin/env bash
set -euo pipefail
sudo systemctl set-property --runtime data-ingest TasksMax=infinity
