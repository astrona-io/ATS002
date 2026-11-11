#!/usr/bin/env bash
set -euo pipefail
sudo sed -i '/^}/i\  /srv/applogs/** rw,' /etc/apparmor.d/usr.sbin.appservice
sudo apparmor_parser -r /etc/apparmor.d/usr.sbin.appservice
sudo aa-enforce /usr/sbin/appservice
sudo systemctl restart appservice
sleep 6
