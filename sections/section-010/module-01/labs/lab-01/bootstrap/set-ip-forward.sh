#!/usr/bin/env bash
# Bootstrap: persistently sets net.ipv4.ip_forward=1 so the lab's
# read-only task has a non-default value to find.

set -eu

echo "net.ipv4.ip_forward = 1" | sudo tee /etc/sysctl.d/99-ip-forward.conf > /dev/null
sudo sysctl --system > /dev/null
