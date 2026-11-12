#!/usr/bin/env bash
set -euo pipefail
sudo apt-get update
sudo mkdir -p /opt/course/apt-research
apt search fail2ban | sudo tee /opt/course/apt-research/fail2ban-search.txt
apt show nginx | sudo tee /opt/course/apt-research/nginx-show.txt
apt-cache policy nginx | sudo tee /opt/course/apt-research/nginx-policy.txt
apt list --installed 2>/dev/null | grep '^python3-' | sudo tee /opt/course/apt-research/python3-installed.txt
apt list --upgradable 2>/dev/null | sudo tee /opt/course/apt-research/upgradable.txt
