#!/usr/bin/env bash
set -euo pipefail
sudo virsh setvcpus web-db 2 --config --maximum
sudo virsh setvcpus web-db 2 --config
sudo virsh setmaxmem web-db 2048M --config
sudo virsh setmem web-db 2048M --config
sudo virsh start web-db
