#!/usr/bin/env bash
set -euo pipefail
sudo sed -i "s/flags=(complain)//" /etc/apparmor.d/usr.sbin.credsync
sudo apparmor_parser -r /etc/apparmor.d/usr.sbin.credsync
