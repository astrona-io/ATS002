#!/usr/bin/env bash
# Bootstrap: creates the web content folder the scenario names. SELinux is
# not active on this machine; the lab grades the script the learner writes.
set -eu

sudo mkdir -p /srv/web/images
echo "<h1>Hangar status page</h1>" | sudo tee /srv/web/index.html >/dev/null
echo "logo placeholder" | sudo tee /srv/web/images/logo.txt >/dev/null
