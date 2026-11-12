#!/usr/bin/env bash
set -euo pipefail
sudo virsh define /root/metrics-cache.xml
sudo virsh autostart metrics-cache
