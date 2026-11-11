#!/usr/bin/env bash
set -euo pipefail
sudo sed -i '/^}/i\  /etc/credsync/api.key r,' /etc/apparmor.d/usr.sbin.credsync
sudo apparmor_parser -r /etc/apparmor.d/usr.sbin.credsync
sudo aa-enforce /usr/sbin/credsync
sudo systemctl restart credsync
sleep 6
