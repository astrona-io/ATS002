#!/usr/bin/env bash
set -euo pipefail
for tool in virsh qemu-img; do command -v "$tool"; done
