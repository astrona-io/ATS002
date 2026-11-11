#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' /usr/local/sbin/archive-logs.sh | sudo at now + 1 day
