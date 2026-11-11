#!/usr/bin/env bash
set -euo pipefail
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y fail2ban
sudo apt-get purge -y ftp
sudo apt-get autoremove -y
