#!/usr/bin/env bash
# Installs `automake` on its own, independently of any group, BEFORE the
# student ever touches the "Development Tools" group. `automake` also
# happens to be a member of that group. This sets up the exact
# tracking-semantics scenario module-05/course.md and question.md
# walk through: dnf group remove only removes what it tracked as installed
# *because of* the group transaction, not every package the group's
# metadata happens to list as a member. A package present beforehand for
# an unrelated reason -- like this one -- survives a later group removal.
#
# Confirms the "Development Tools" group itself is genuinely NOT installed
# yet, so the student's group install in Part III of the lab is real work,
# not a no-op.

set -eu

echo "Installing automake on its own inside rpmbox (independent of any group)..."
sudo docker exec rpmbox dnf -y install automake

echo "Confirming automake is installed but the Development Tools group is not..."
sudo docker exec rpmbox bash -c '
  set -eu
  rpm -q automake
  if dnf group list installed 2>/dev/null | grep -qi "Development Tools"; then
    echo "unexpected: Development Tools group already shows as installed" >&2
    exit 1
  fi
'

echo "rpmbox dnf-groups scenario ready: automake pre-installed independently, Development Tools group not yet installed."
