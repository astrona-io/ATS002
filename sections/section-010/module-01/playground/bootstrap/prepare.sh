#!/usr/bin/env bash
# OS prep for the sysctl playground. Nothing to install — the lfcs image
# already has procps (sysctl), coreutils, and systemd (timedatectl). This
# script only leaves a hint; there is no task and no grading.
set -eu

echo "[playground] sysctl-live-kernel: ready."
echo "[playground] try:  uname -r  ;  sysctl net.ipv4.ip_forward  ;  cat /proc/sys/net/ipv4/ip_forward"
