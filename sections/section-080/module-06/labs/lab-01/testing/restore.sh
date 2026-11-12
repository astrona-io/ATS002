#!/usr/bin/env bash
set -euo pipefail
sudo mv /tmp/initrd.saved "/boot/initrd.img-$(uname -r)"
