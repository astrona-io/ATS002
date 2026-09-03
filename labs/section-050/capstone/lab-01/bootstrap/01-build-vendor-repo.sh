#!/usr/bin/env bash
# Bootstrap: builds the "vendor" side of a fake telemetry-agent
# third-party repository entirely locally, so the student can practice
# the full signed-by + sources.list.d + pinned-install + hold workflow
# against a genuinely working repository, with zero dependency on a real
# external vendor being reachable or stable. Same technique as lab-051.
#
#   1. Generates a dedicated GPG signing key for the fake vendor (no
#      passphrase, so key generation is non-interactive).
#   2. Builds one minimal, real .deb package named "telemetry-agent" at a
#      vendor-specific version string.
#   3. Publishes it into a reprepro-managed repository at /srv/vendor-repo.
#   4. Exports the vendor's public key as an ASCII-armored file into the
#      served repo directory, so the student fetches it the same way a
#      real vendor's published signing key would be fetched.
#
# Deliberately NOT done here: pre-configuring APT's client-side trust of
# this repository. That full chain is the student's task -- see
# question.md.

set -eu

ARCH="$(dpkg --print-architecture)"
VENDOR_VERSION="2.4.0-1~apptoolsfake1"
REPO_DIR="/srv/vendor-repo"
CODENAME="app-tools"
GPG_NAME="App Tools Vendor Packaging"
GPG_EMAIL="packaging@app-tools.example"

sudo mkdir -p /opt/lab-meta
echo "${VENDOR_VERSION}" | sudo tee /opt/lab-meta/telemetry-agent-vendor-version >/dev/null

# --- 1. Generate the vendor's GPG signing key (root's keyring, no passphrase) ---
sudo mkdir -p /root/.gnupg
sudo chmod 700 /root/.gnupg

cat <<EOF | sudo tee /tmp/vendor-gpg-genkey >/dev/null
%no-protection
Key-Type: RSA
Key-Length: 2048
Name-Real: ${GPG_NAME}
Name-Email: ${GPG_EMAIL}
Expire-Date: 0
%commit
EOF

sudo gpg --batch --gen-key /tmp/vendor-gpg-genkey
sudo rm -f /tmp/vendor-gpg-genkey

VENDOR_KEYID="$(sudo gpg --list-secret-keys --with-colons "${GPG_EMAIL}" | awk -F: '/^sec:/{print $5; exit}')"

# --- 2. Build the fake telemetry-agent .deb (a minimal, harmless stub package) ---
BUILD_DIR="$(sudo mktemp -d)"
sudo mkdir -p "${BUILD_DIR}/DEBIAN" "${BUILD_DIR}/usr/share/doc/telemetry-agent-vendor-build"

cat <<EOF | sudo tee "${BUILD_DIR}/DEBIAN/control" >/dev/null
Package: telemetry-agent
Version: ${VENDOR_VERSION}
Architecture: ${ARCH}
Maintainer: ${GPG_NAME} <${GPG_EMAIL}>
Section: admin
Priority: optional
Installed-Size: 4
Description: Vendor build of telemetry-agent (lab simulation stub)
 This is a deliberately minimal stub package standing in for a real
 internal vendor build of a telemetry-collection agent, used to practice
 trusting and pinning a third-party APT repository as part of new server
 onboarding. It installs no actual running service.
EOF

echo "${VENDOR_VERSION}" | sudo tee "${BUILD_DIR}/usr/share/doc/telemetry-agent-vendor-build/BUILD_INFO" >/dev/null

DEB_PATH="/tmp/telemetry-agent_${VENDOR_VERSION}_${ARCH}.deb"
sudo dpkg-deb --build --root-owner-group "${BUILD_DIR}" "${DEB_PATH}"

# --- 3. Set up the reprepro-managed repository and publish the package ---
sudo mkdir -p "${REPO_DIR}/conf"

cat <<EOF | sudo tee "${REPO_DIR}/conf/distributions" >/dev/null
Codename: ${CODENAME}
Components: main
Architectures: ${ARCH}
SignWith: ${VENDOR_KEYID}
Description: Vendor app-tools repository (lab simulation, local-only)
EOF

sudo reprepro -b "${REPO_DIR}" includedeb "${CODENAME}" "${DEB_PATH}"

# --- 4. Publish the vendor's public key alongside the served repo ---
sudo gpg --armor --export "${GPG_EMAIL}" | sudo tee "${REPO_DIR}/app-tools-archive-keyring.asc" >/dev/null

sudo chmod -R a+rX "${REPO_DIR}"
