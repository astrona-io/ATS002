#!/usr/bin/env bash
# Sets the default boot target to graphical.target so the task (change it
# to multi-user.target) has a real starting point. graphical.target always
# exists on a systemd system even without a display manager installed.
set -eu

sudo systemctl set-default graphical.target

echo "lab-016f bootstrap: default boot target is now:"
systemctl get-default
readlink -f /etc/systemd/system/default.target || true
