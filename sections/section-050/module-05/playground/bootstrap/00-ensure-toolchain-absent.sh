#!/usr/bin/env bash
# Bootstrap: defensively ensures build-essential, git, cmake, and
# pkg-config are not installed, regardless of what the base VM image
# happens to carry (git in particular is commonly pre-installed on
# server images), so the "install this toolchain in one transaction"
# task always starts from a genuinely clean baseline.

set -eu

sudo apt-get update -y

for pkg in build-essential git cmake pkg-config; do
  if dpkg -s "$pkg" >/dev/null 2>&1; then
    sudo DEBIAN_FRONTEND=noninteractive apt-get purge -y "$pkg"
  fi
done

sudo apt-get autoremove -y
