#!/usr/bin/env bash
# Bootstrap: builds and installs a small, real, locally-built stand-in
# "observability agent module family" -- three minimal .deb packages
# sharing the obsagent- name prefix, installed directly with dpkg -i.
# Same technique as lab-052's logtail-utils and lab-055's PHP 8.1
# stand-in family: real, minimal .deb packages built locally so the
# student practices "find and bulk-hold an installed package family by
# naming pattern" against a genuinely installed, genuinely interrogable
# set of packages, without depending on any package actually existing in
# a real repository.
#
# The student's task is only to find this family by pattern and hold it
# -- these packages are already installed by the time the student logs
# in.

set -eu

ARCH="$(dpkg --print-architecture)"
VERSION="3.2.0-1"
MAINTAINER="Platform Observability Team <observability@internal.example>"

build_and_install() {
  local pkg_name="$1"
  local description="$2"

  local build_dir
  build_dir="$(sudo mktemp -d)"
  sudo mkdir -p "${build_dir}/DEBIAN" "${build_dir}/usr/share/doc/${pkg_name}"

  cat <<EOF | sudo tee "${build_dir}/DEBIAN/control" >/dev/null
Package: ${pkg_name}
Version: ${VERSION}
Architecture: ${ARCH}
Maintainer: ${MAINTAINER}
Section: admin
Priority: optional
Installed-Size: 4
Description: ${description}
 Locally-built lab stand-in for an internal observability-agent module,
 part of a family of packages sharing the obsagent- prefix. Installs no
 real running service.
EOF

  echo "${pkg_name} ${VERSION} (lab stand-in)" | sudo tee "${build_dir}/usr/share/doc/${pkg_name}/BUILD_INFO" >/dev/null

  local deb_path="/tmp/${pkg_name}_${VERSION}_${ARCH}.deb"
  sudo dpkg-deb --build --root-owner-group "${build_dir}" "${deb_path}"
  sudo dpkg -i "${deb_path}"
}

build_and_install "obsagent-core" "Core runtime for the observability agent"
build_and_install "obsagent-net"  "Network metrics collector module for the observability agent"
build_and_install "obsagent-disk" "Disk/IO metrics collector module for the observability agent"

echo "obsagent family installed:"
dpkg -l | grep -E '^ii  obsagent-'
