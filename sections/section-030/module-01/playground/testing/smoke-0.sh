#!/usr/bin/env bash
set -euo pipefail
for tool in gcc make; do command -v "$tool"; done
