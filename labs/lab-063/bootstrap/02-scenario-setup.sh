#!/usr/bin/env bash
# Prepares the dnf-basics scenario inside rpmbox:
#  - Enables EPEL (fail2ban is not in Rocky's default BaseOS/AppStream
#    repos -- it's a standard EPEL package, so a plain `dnf install
#    fail2ban` needs EPEL enabled first, same as it would on a real
#    Rocky/RHEL server).
#  - Installs telnet (the student must remove it + autoremove orphans).
#  - Confirms fail2ban and mtr (the deliberately-bundled "unwanted"
#    package the student will use to simulate a colleague's mistake in
#    docs/question.md Step 3) are NOT pre-installed.

set -eu

echo "Enabling EPEL inside rpmbox..."
sudo docker exec rpmbox dnf -y install epel-release
sudo docker exec rpmbox dnf -y makecache

echo "Installing telnet inside rpmbox (the student's removal target)..."
sudo docker exec rpmbox dnf -y install telnet

echo "Confirming fail2ban and mtr are not pre-installed..."
sudo docker exec rpmbox bash -c '
  set -eu
  if rpm -q fail2ban >/dev/null 2>&1; then
    echo "unexpected: fail2ban already installed" >&2
    exit 1
  fi
  if rpm -q mtr >/dev/null 2>&1; then
    echo "unexpected: mtr already installed" >&2
    exit 1
  fi
'

echo "rpmbox dnf-basics scenario ready: telnet installed, fail2ban/mtr absent, EPEL enabled."
