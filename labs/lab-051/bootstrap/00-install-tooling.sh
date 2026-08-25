#!/usr/bin/env bash
# Bootstrap: installs the tooling needed to stand up a small, fully real
# local APT repository inside this VM -- reprepro (repo management, and
# automatic GPG signing of the Release file), gnupg (key generation),
# dpkg-dev (dpkg-deb / dpkg-scanpackages), and python3 (to serve the repo
# over HTTP). The "vendor" in this lab is entirely simulated on
# 127.0.0.1 -- the lab has no dependency on reaching any real external
# third party, which keeps it self-contained and reliable to grade.

set -eu

sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y gnupg reprepro dpkg-dev python3
