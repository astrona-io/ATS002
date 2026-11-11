#!/usr/bin/env bash
set -euo pipefail
sudo mv /etc/udev/rules.d/99-backup-drive.rules.ci-saved /etc/udev/rules.d/99-backup-drive.rules
