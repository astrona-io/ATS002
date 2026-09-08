#!/usr/bin/env bash
# Puts the journal into the "logs are lost on reboot" default state and
# removes any size cap, so the task (make it persistent + bounded) has a
# real starting point.
#
#   - Storage=auto (the default) + no /var/log/journal directory  => volatile
#   - no SystemMaxUse set                                          => uncapped
set -eu

# Make sure no persistent journal dir exists.
sudo rm -rf /var/log/journal
sudo mkdir -p /run/log/journal

# Reset journald.conf to a known bare state (comments only).
sudo tee /etc/systemd/journald.conf >/dev/null <<'EOF'
# See journald.conf(5) for details.
[Journal]
#Storage=auto
#SystemMaxUse=
EOF
sudo rm -f /etc/systemd/journald.conf.d/*.conf 2>/dev/null || true

sudo systemctl restart systemd-journald

echo "lab-016e bootstrap: journald is volatile (no /var/log/journal) and uncapped."
journalctl --header 2>/dev/null | grep -i 'storage\|file' | head -3 || true
