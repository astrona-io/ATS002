#!/usr/bin/env bash
set -euo pipefail
sudo mkdir -p /etc/udev/rules.d
sudo tee /etc/udev/rules.d/99-backup-drive.rules >/dev/null <<'REFERENCE_FILE'
SUBSYSTEM=="block", ENV{DEVTYPE}=="disk", ATTRS{serial}=="lab014-backup-drive", SYMLINK+="backup-drive"
SUBSYSTEM=="block", ENV{DEVTYPE}=="partition", ATTRS{serial}=="lab014-backup-drive", SYMLINK+="backup-drive%n"
REFERENCE_FILE
sudo udevadm control --reload-rules
sudo udevadm trigger --subsystem-match=block
sudo udevadm settle
