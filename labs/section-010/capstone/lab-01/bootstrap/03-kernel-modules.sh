#!/usr/bin/env bash
# Bootstrap: ensures pcspkr is loaded (simulating the "already beeping"
# starting state), and ensures dummy is NOT already loaded, so the student
# has a clean, deterministic starting point for both module tasks regardless
# of what the underlying QEMU platform auto-loads.

set -eu

sudo modprobe pcspkr || true
sudo modprobe -r dummy 2>/dev/null || true
