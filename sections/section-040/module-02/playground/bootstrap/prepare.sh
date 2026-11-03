#!/usr/bin/env bash
# OS prep for PLAYGROUND — SELinux Commands
#
# This machine runs AppArmor and cannot run SELinux. The script only stages
# real paths for the learner to name in commands, and an empty notes file.
# There is no task and no grading.
set -euo pipefail

sudo mkdir -p /srv/web/images
echo "<h1>Hangar status page</h1>" | sudo tee /srv/web/index.html >/dev/null
echo "logo placeholder" | sudo tee /srv/web/images/logo.txt >/dev/null
sudo touch /root/selinux-notes.sh
echo "[playground] selinux-commands-bay: ready. SELinux is not active here; write commands in /root/selinux-notes.sh."
