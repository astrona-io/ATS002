#!/usr/bin/env bash
# Bootstrap: defensively ensures fail2ban is not installed, regardless of
# what the base VM image happens to carry, so the "install fail2ban" task
# always starts from a genuinely clean baseline.

set -eu

sudo apt-get update -y

if dpkg -s fail2ban >/dev/null 2>&1; then
  sudo DEBIAN_FRONTEND=noninteractive apt-get purge -y fail2ban
fi
