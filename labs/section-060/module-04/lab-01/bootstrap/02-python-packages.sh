#!/usr/bin/env bash
# Ensures there are several python3-* packages installed inside rpmbox
# (beyond whatever the base image ships, e.g. python3 itself as a dnf
# dependency) so the "list installed python3-* packages" research step has
# a genuinely meaningful, non-trivial result.

set -eu

echo "Installing a few extra python3-* packages inside rpmbox..."
sudo docker exec rpmbox dnf -y install python3-pip python3-setuptools python3-requests

echo "Confirming installed python3-* packages inside rpmbox:"
sudo docker exec rpmbox bash -c "dnf list installed | grep '^python3-'"
