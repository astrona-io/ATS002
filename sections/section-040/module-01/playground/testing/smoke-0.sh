#!/usr/bin/env bash
set -euo pipefail
for tool in aa-status apparmor_parser; do command -v "$tool"; done
