#!/usr/bin/env bash
# Bootstrap: builds and installs a small, real, locally-built stand-in
# for a "PHP 8.1 module family" -- six minimal .deb packages sharing the
# php8.1- name prefix, installed directly with dpkg -i.
#
# Ubuntu 24.04 (noble) ships PHP 8.3 in its own default archive and
# carries no real php8.1-* packages at all, so there is nothing to
# `apt install` here that would actually exercise the "find and bulk-hold
# an installed package family by naming pattern" skill this lab is
# about. Building real, minimal .deb packages locally (the same
# technique used in the dpkg lab for logtail-utils) reproduces exactly
# the situation the scenario needs -- a genuinely installed family of
# packages sharing a naming pattern, each independently interrogable and
# holdable via the real dpkg/apt-mark database -- without depending on
# any package actually existing in a real repository.
#
# The student's task is only to find this family by pattern and hold it
# -- these packages are already installed by the time the student logs
# in.

set -eu

ARCH="$(dpkg --print-architecture)"
VERSION="8.1.2-1ubuntu2.14"
MAINTAINER="PHP Packaging Team <php-packaging@internal.example>"

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
Section: php
Priority: optional
Installed-Size: 4
Description: ${description}
 Locally-built lab stand-in for the real ${pkg_name} package, standing in
 for a full PHP 8.1 module family that Ubuntu 24.04's default archive
 does not carry (it ships PHP 8.3 instead). Installs no real PHP
 runtime.
EOF

  echo "${pkg_name} ${VERSION} (lab stand-in)" | sudo tee "${build_dir}/usr/share/doc/${pkg_name}/BUILD_INFO" >/dev/null

  local deb_path="/tmp/${pkg_name}_${VERSION}_${ARCH}.deb"
  sudo dpkg-deb --build --root-owner-group "${build_dir}" "${deb_path}"
  sudo dpkg -i "${deb_path}"
}

build_and_install "php8.1-common"  "Common files for PHP 8.1"
build_and_install "php8.1-cli"     "Command-line interpreter for PHP 8.1"
build_and_install "php8.1-fpm"     "FastCGI Process Manager for PHP 8.1"
build_and_install "php8.1-mysql"   "MySQL module for PHP 8.1"
build_and_install "php8.1-curl"    "CURL module for PHP 8.1"
build_and_install "php8.1-xml"     "DOM/XML module for PHP 8.1"

echo "PHP 8.1 family installed:"
dpkg -l | grep -E '^ii  php8\.1-'
