#!/usr/bin/env bash
set -euo pipefail
sudo sed -i '/^}/i\  /srv/applogs/** rw,' /etc/apparmor.d/usr.sbin.appservice
sudo apparmor_parser -r /etc/apparmor.d/usr.sbin.appservice
sudo sed -i "s/flags=(complain)//" /etc/apparmor.d/usr.sbin.appservice
sudo apparmor_parser -r /etc/apparmor.d/usr.sbin.appservice
sudo systemctl restart appservice
sleep 6
