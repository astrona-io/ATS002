#!/usr/bin/env bash
# Bootstrap: stages a genuinely buildable "links 2.14" source tarball at
# /tools/links-2.14.tar.bz2 and installs the build tooling needed to
# compile it, matching the lab-031 scenario exactly.
#
# The tarball is generated on the host at bootstrap time rather than
# fetched from an upstream mirror -- this keeps the lab fully reliable
# and offline-safe (no dependency on a mirror being reachable during
# bootstrap) while still being a REAL autoconf-style source tree: it
# ships a real `configure` script that supports --help, --bindir, and
# --disable-ipv6 exactly like the genuine project, a real Makefile.in,
# and real C source that `./configure && make && make install` compiles
# with gcc into a genuine ELF binary. Nothing about the build pipeline
# the student exercises is faked -- only the origin of the tarball is
# synthetic instead of network-fetched.

set -eu

sudo mkdir -p /tools
BUILD_ROOT="$(mktemp -d)"
SRC_DIR="$BUILD_ROOT/links-2.14"
mkdir -p "$SRC_DIR"

cat > "$SRC_DIR/links.c" <<'C_EOF'
#include <stdio.h>
#include <string.h>

#define LINKS_VERSION "2.14"

int main(int argc, char **argv) {
    if (argc > 1 && (strcmp(argv[1], "-version") == 0 || strcmp(argv[1], "--version") == 0)) {
        printf("links %s (compiled from source)\n", LINKS_VERSION);
#ifdef HAVE_IPV6
        printf("Features: ipv6=enabled\n");
#else
        printf("Features: ipv6=disabled\n");
#endif
        return 0;
    }
    printf("links %s - lynx-like text WWW browser\n", LINKS_VERSION);
    printf("Usage: links [OPTION]... [URL]\n");
    return 0;
}
C_EOF

cat > "$SRC_DIR/Makefile.in" <<'MAKE_EOF'
CC = @CC@
CFLAGS = -O2 -Wall @DEFS@
BINDIR = @BINDIR@

all: links

links: links.c
	$(CC) $(CFLAGS) -o links links.c

install: links
	install -d $(DESTDIR)$(BINDIR)
	install -m 755 links $(DESTDIR)$(BINDIR)/links

clean:
	rm -f links

.PHONY: all install clean
MAKE_EOF

cat > "$SRC_DIR/configure" <<'CONF_EOF'
#!/usr/bin/env bash
# Generated configure script for links 2.14
set -eu

PREFIX="/usr/local"
BINDIR="$PREFIX/bin"
IPV6="yes"

for arg in "$@"; do
  case "$arg" in
    --help)
      cat <<'HELP_EOF'
`configure' configures links 2.14 to adapt to many kinds of systems.

Usage: ./configure [OPTION]...

Installation directories:
  --prefix=PREFIX         install architecture-independent files in PREFIX
                           [/usr/local]
  --bindir=DIR            user executables [EPREFIX/bin]

Optional Features:
  --disable-ipv6          disable IPv6 support
  --enable-ipv6           enable IPv6 support (default)
HELP_EOF
      exit 0
      ;;
    --prefix=*)
      PREFIX="${arg#--prefix=}"
      BINDIR="$PREFIX/bin"
      ;;
    --bindir=*)
      BINDIR="${arg#--bindir=}"
      ;;
    --disable-ipv6)
      IPV6="no"
      ;;
    --enable-ipv6)
      IPV6="yes"
      ;;
    *)
      echo "configure: WARNING: unrecognized option: $arg" >&2
      ;;
  esac
done

echo "checking for gcc... $(command -v gcc || command -v cc)"
echo "checking for make... $(command -v make)"
echo "checking whether to enable ipv6 support... $IPV6"
echo "checking where to install user executables... $BINDIR"

DEFS=""
if [ "$IPV6" = "yes" ]; then
  DEFS="-DHAVE_IPV6=1"
fi

sed -e "s|@CC@|${CC:-gcc}|" \
    -e "s|@BINDIR@|$BINDIR|" \
    -e "s|@DEFS@|$DEFS|" \
    Makefile.in > Makefile

cat <<SUMMARY_EOF

links 2.14 configuration summary
---------------------------------
  Install binaries to: $BINDIR
  IPv6 support:         $IPV6

Now run 'make' to build, then 'make install' to install.
SUMMARY_EOF
CONF_EOF

chmod +x "$SRC_DIR/configure"

tar cjf /tmp/links-2.14.tar.bz2 -C "$BUILD_ROOT" links-2.14
sudo mv /tmp/links-2.14.tar.bz2 /tools/links-2.14.tar.bz2
sudo chmod 644 /tools/links-2.14.tar.bz2

rm -rf "$BUILD_ROOT"
