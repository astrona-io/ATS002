#!/usr/bin/env bash
set -euo pipefail
for tool in sysctl modprobe systemctl; do command -v "$tool"; done
