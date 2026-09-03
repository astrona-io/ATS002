#!/usr/bin/env bash
# Bootstrap: refreshes the package index and installs several real,
# genuinely-in-the-archive python3-* packages, so the "list every
# installed package matching python3-*" research task has a real,
# non-trivial set of results to find -- regardless of what the base VM
# image happened to already carry.
#
# nginx and fail2ban are deliberately NOT touched here -- the research
# tasks target them specifically because they are not installed (nginx's
# Installed:/Candidate: comparison, fail2ban's keyword search), so
# leaving them alone is intentional, not an oversight.

set -eu

sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
  python3-pip \
  python3-venv \
  python3-dev \
  python3-setuptools \
  python3-wheel
