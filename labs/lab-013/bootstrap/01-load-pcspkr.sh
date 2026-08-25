#!/usr/bin/env bash
# Bootstrap: ensures pcspkr is loaded, simulating the "already beeping"
# starting state the scenario describes. Some virtualized environments
# don't auto-load it via hardware detection, so this loads it explicitly
# to guarantee a deterministic starting state regardless of the underlying
# QEMU platform's speaker emulation.

set -eu

sudo modprobe pcspkr || true
