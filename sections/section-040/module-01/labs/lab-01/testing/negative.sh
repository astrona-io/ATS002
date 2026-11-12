#!/usr/bin/env bash
set -euo pipefail
sudo apparmor_parser -r -C /etc/apparmor.d/usr.sbin.appservice
