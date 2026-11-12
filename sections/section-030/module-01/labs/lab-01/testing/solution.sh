#!/usr/bin/env bash
set -euo pipefail
cd /tmp
tar xjf /tools/links-2.14.tar.bz2
cd links-2.14
./configure --bindir=/usr/bin --disable-ipv6
make
sudo make install
