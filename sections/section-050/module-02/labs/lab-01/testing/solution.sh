#!/usr/bin/env bash
set -euo pipefail
sudo dpkg -i /home/candidate/downloads/logtail-utils_2.3.1_*.deb
sudo dpkg --configure -a
sudo DEBIAN_FRONTEND=noninteractive apt-get -f install -y
