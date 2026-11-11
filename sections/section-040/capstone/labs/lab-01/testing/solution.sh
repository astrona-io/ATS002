#!/usr/bin/env bash
set -euo pipefail
sudo sed -i '/^}/i\  /srv/shiplogs/** rw,' /etc/apparmor.d/usr.sbin.logshipper
sudo apparmor_parser -r /etc/apparmor.d/usr.sbin.logshipper
sudo aa-enforce /usr/sbin/logshipper
sudo systemctl restart logshipper
sudo sed -i '/^}/i\  /etc/metrics-agent/remote.conf r,' /etc/apparmor.d/usr.sbin.metrics-agent
sudo apparmor_parser -r /etc/apparmor.d/usr.sbin.metrics-agent
sudo aa-enforce /usr/sbin/metrics-agent
sudo systemctl restart metrics-agent
sleep 6
