#!/usr/bin/env bash
# Bootstrap: defensively ensures curl, git, and jq are not installed,
# regardless of what the base VM image happens to carry, so the
# "install the baseline ops toolchain in one transaction" task always
# starts from a genuinely clean baseline. Runs after 02-serve-vendor-repo.sh
# (which still needs curl to health-check the vendor repo service) so the
# ordering here is deliberate, not incidental.

set -eu

for pkg in curl git jq; do
  if dpkg -s "$pkg" >/dev/null 2>&1; then
    sudo DEBIAN_FRONTEND=noninteractive apt-get purge -y "$pkg"
  fi
done

sudo apt-get autoremove -y
