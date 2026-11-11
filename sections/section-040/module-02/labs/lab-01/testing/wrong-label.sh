#!/usr/bin/env bash
set -eu
sudo chcon -R -t user_home_t /srv/web
