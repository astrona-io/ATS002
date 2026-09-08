#!/usr/bin/env bash
# Ensures the starting state for an APT pinning task:
#   - curl is installed
#   - the noble release pocket AND noble-updates are both enabled, so
#     `apt-cache policy curl` shows two versions: a lower one from
#     `noble/main` and a higher one from `noble-updates/main`
#   - no pin exists yet, so the higher (updates) version is the Candidate
set -eu

export DEBIAN_FRONTEND=noninteractive

# Make sure both pockets are present in sources (they are by default on the
# stock image, but don't assume).
if ! grep -rqs 'noble-updates' /etc/apt/sources.list /etc/apt/sources.list.d/ /etc/apt/sources.list.d/*.sources 2>/dev/null; then
  echo "Warning: noble-updates not found in sources; adding a minimal entry." >&2
  echo 'deb http://archive.ubuntu.com/ubuntu noble-updates main' | sudo tee /etc/apt/sources.list.d/noble-updates.list >/dev/null
fi

sudo apt-get update -qq || true
sudo apt-get install -y -qq curl || true

# Clear any stray preferences so the task starts from an unpinned state.
sudo rm -f /etc/apt/preferences.d/*curl* 2>/dev/null || true

echo "lab-051b bootstrap: current curl candidate ->"
apt-cache policy curl | sed 's/^/  /'
