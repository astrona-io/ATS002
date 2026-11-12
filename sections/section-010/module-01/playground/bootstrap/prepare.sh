#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# OS prep for the sysctl playground. Nothing to install — the lfcs image
# already has procps (sysctl), coreutils, and systemd (timedatectl). This
# script only leaves a hint; there is no task and no grading.
set -eu

echo "[playground] sysctl-live-kernel: ready."
echo "[playground] try:  uname -r  ;  sysctl net.ipv4.ip_forward  ;  cat /proc/sys/net/ipv4/ip_forward"
ASTRONA_STUDENT_SCRIPT
