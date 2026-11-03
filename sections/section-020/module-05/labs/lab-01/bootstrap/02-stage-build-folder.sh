#!/usr/bin/env bash
# Bootstrap: stages the build folder with the web page to pack into the image
# and pulls the base image, so the build does not depend on a slow download.

set -eu

sudo docker pull nginx:alpine

sudo mkdir -p /opt/course/25/build
sudo tee /opt/course/25/build/index.html >/dev/null <<'HTML'
<h1>Status page</h1>
<p>All systems go.</p>
HTML
sudo chmod 0777 /opt/course/25/build
sudo chmod 0644 /opt/course/25/build/index.html
