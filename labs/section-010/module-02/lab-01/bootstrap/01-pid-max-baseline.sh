#!/usr/bin/env bash
# Bootstrap: forces kernel.pid_max down to its legacy default (32768) both
# live and via a low-priority sysctl.d drop-in, so the "raise it" task has
# a real starting ceiling to fix. Modern distro defaults sometimes already
# ship pid_max raised, which would make the task trivially already-done --
# this guarantees a deterministic starting state.

set -eu

sudo sysctl -w kernel.pid_max=32768 > /dev/null

echo "kernel.pid_max = 32768" | sudo tee /etc/sysctl.d/01-pid-max-baseline.conf > /dev/null
sudo sysctl --system > /dev/null
