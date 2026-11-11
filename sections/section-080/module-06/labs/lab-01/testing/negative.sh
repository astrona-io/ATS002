#!/usr/bin/env bash
set -euo pipefail
sudo mv "/boot/initrd.img-$(uname -r)" /tmp/initrd.saved
