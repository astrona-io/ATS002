#!/usr/bin/env bash
set -euo pipefail
for tool in apt-cache dpkg; do command -v "$tool"; done
