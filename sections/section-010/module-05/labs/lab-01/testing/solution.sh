#!/usr/bin/env bash
set -euo pipefail
sudo pkill -KILL -f '/usr/local/bin/[c]ollector2'
sudo mv /usr/local/bin/collector2 /tmp/collector2.disabled
