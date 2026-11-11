#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
set -euo pipefail

if ! id pilot >/dev/null 2>&1; then
  sudo useradd -m -s /bin/bash pilot
fi

# Rootless containers need subordinate IDs. Lingering is left off on purpose.
if ! grep -q '^pilot:' /etc/subuid; then
  sudo usermod --add-subuids 100000-165535 pilot
fi
if ! grep -q '^pilot:' /etc/subgid; then
  sudo usermod --add-subgids 100000-165535 pilot
fi

sudo loginctl disable-linger pilot || true
ASTRONA_STUDENT_SCRIPT
