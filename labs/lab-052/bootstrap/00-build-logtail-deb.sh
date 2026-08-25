#!/usr/bin/env bash
# Bootstrap: builds a small, real .deb package -- logtail-utils -- and
# stages it under /home/candidate/downloads/, standing in for "a
# colleague handed you a standalone .deb, not available in any
# configured repository." The student inspects it, installs it directly
# with dpkg, and confirms ownership in both directions. Nothing here
# pre-installs the package -- that is the student's task.

set -eu

ARCH="$(dpkg --print-architecture)"
VERSION="2.3.1"
PKG_NAME="logtail-utils"

sudo mkdir -p /home/candidate/downloads

BUILD_DIR="$(sudo mktemp -d)"
sudo mkdir -p "${BUILD_DIR}/DEBIAN" "${BUILD_DIR}/usr/bin" "${BUILD_DIR}/usr/share/doc/${PKG_NAME}"

cat <<EOF | sudo tee "${BUILD_DIR}/DEBIAN/control" >/dev/null
Package: ${PKG_NAME}
Version: ${VERSION}
Architecture: ${ARCH}
Maintainer: Internal Tools <tools@internal.example>
Section: utils
Priority: optional
Installed-Size: 8
Description: Internal log-tailing helper
 A small internal wrapper around 'tail -f' that prefixes each line with a
 timestamp, used by the ops team for quick log inspection. Not published
 to any package repository.
EOF

sudo tee "${BUILD_DIR}/usr/bin/logtail" >/dev/null <<'EOF'
#!/usr/bin/env bash
# logtail: a trivial internal wrapper around `tail -f` that prefixes each
# line with a timestamp. Part of the logtail-utils internal tool package.
set -eu
if [[ $# -lt 1 ]]; then
  echo "usage: logtail <file> [more files...]" >&2
  exit 2
fi
exec tail -f "$@" | while IFS= read -r line; do
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$line"
done
EOF
sudo chmod 755 "${BUILD_DIR}/usr/bin/logtail"

sudo tee "${BUILD_DIR}/usr/share/doc/${PKG_NAME}/README" >/dev/null <<EOF
logtail-utils ${VERSION}
Internal log-tailing helper. See 'logtail --help' is not implemented;
run 'logtail <file>' directly.
EOF

DEB_PATH="/home/candidate/downloads/${PKG_NAME}_${VERSION}_${ARCH}.deb"
sudo dpkg-deb --build --root-owner-group "${BUILD_DIR}" "${DEB_PATH}"

sudo chmod -R a+rX /home/candidate
sudo chmod 644 "${DEB_PATH}"
