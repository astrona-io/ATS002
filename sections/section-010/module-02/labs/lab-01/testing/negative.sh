#!/usr/bin/env bash
set -euo pipefail
sudo sysctl -w kernel.pid_max=32768
