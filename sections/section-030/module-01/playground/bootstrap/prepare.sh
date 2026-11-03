#!/usr/bin/env bash
# OS prep for PLAYGROUND -- Compile & Install From Source
#
# Runs once when the environment comes up. Environment preparation only:
# make sure the build tools are installed and stage a genuinely buildable
# "links 2.14" source tarball at /tools/links-2.14.tar.bz2.
#
# The tarball is generated on the host at start-up rather than fetched
# from a mirror, so the playground works offline. It is a real
# autoconf-style tree: a `configure` script that supports --help,
# --bindir and --disable-ipv6, a Makefile.in and C source that gcc
# compiles into an ELF binary. There is no task and no grading.
set -euo pipefail

echo "[playground] source-build-bay: checking build tools ..."
if ! command -v gcc >/dev/null 2>&1 || ! command -v make >/dev/null 2>&1; then
  export DEBIAN_FRONTEND=noninteractive
  sudo apt-get update -qq
  sudo apt-get install -y -qq build-essential
fi

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

echo "[playground] source-build-bay: ready. Tarball: /tools/links-2.14.tar.bz2"
