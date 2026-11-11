#!/usr/bin/env bash
set -euo pipefail
for tool in systemctl crontab docker; do command -v "$tool"; done
