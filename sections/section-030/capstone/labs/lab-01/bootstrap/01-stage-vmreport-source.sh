#!/usr/bin/env bash
# Bootstrap (1/2): stages a genuinely buildable "vmreport 1.0" source
# tarball at /tools/vmreport-1.0.tar.gz and installs build tooling.
#
# vmreport is a small internal reporting tool: once built and installed,
# `vmreport <domain-name>` shells out to `virsh dominfo <domain-name>`
# and prints a one-line status summary -- deliberately tying this
# module's compile-from-source skill directly to the libvirt domain the
# student defines in the second half of this capstone. Like lab-031,
# the tarball is generated on the host at bootstrap time (not fetched
# from a mirror) to keep the lab fully reliable and offline-safe, but
# the source is a REAL autoconf-style project: a real `configure`
# script supporting --help / --bindir / --disable-color, a real
# Makefile.in, and real C source that `./configure && make && make
# install` compiles with gcc into a genuine ELF binary.

set -eu

sudo mkdir -p /tools
BUILD_ROOT="$(mktemp -d)"
SRC_DIR="$BUILD_ROOT/vmreport-1.0"
mkdir -p "$SRC_DIR"

cat > "$SRC_DIR/vmreport.c" <<'C_EOF'
#include <stdio.h>
#include <string.h>

#define VMREPORT_VERSION "1.0"

#ifdef ENABLE_COLOR
#define COLOR_ON  "\033[32m"
#define COLOR_OFF "\033[0m"
#else
#define COLOR_ON  ""
#define COLOR_OFF ""
#endif

int main(int argc, char **argv) {
    if (argc > 1 && (strcmp(argv[1], "-version") == 0 || strcmp(argv[1], "--version") == 0)) {
        printf("vmreport %s (compiled from source)\n", VMREPORT_VERSION);
#ifdef ENABLE_COLOR
        printf("Features: color=enabled\n");
#else
        printf("Features: color=disabled\n");
#endif
        return 0;
    }

    if (argc < 2) {
        fprintf(stderr, "usage: vmreport <domain-name>\n");
        return 1;
    }

    char cmd[512];
    snprintf(cmd, sizeof(cmd), "virsh dominfo %s 2>/dev/null", argv[1]);

    FILE *fp = popen(cmd, "r");
    if (!fp) {
        fprintf(stderr, "vmreport: failed to query libvirt\n");
        return 1;
    }

    char line[256];
    char state[64] = "unknown";
    while (fgets(line, sizeof(line), fp)) {
        if (strncmp(line, "State:", 6) == 0) {
            char *p = line + 6;
            while (*p == ' ' || *p == '\t') p++;
            strncpy(state, p, sizeof(state) - 1);
            state[strcspn(state, "\n")] = 0;
        }
    }
    pclose(fp);

    printf("%svmreport: domain '%s' state=%s%s\n", COLOR_ON, argv[1], state, COLOR_OFF);
    return 0;
}
C_EOF

cat > "$SRC_DIR/Makefile.in" <<'MAKE_EOF'
CC = @CC@
CFLAGS = -O2 -Wall @DEFS@
BINDIR = @BINDIR@

all: vmreport

vmreport: vmreport.c
	$(CC) $(CFLAGS) -o vmreport vmreport.c

install: vmreport
	install -d $(DESTDIR)$(BINDIR)
	install -m 755 vmreport $(DESTDIR)$(BINDIR)/vmreport

clean:
	rm -f vmreport

.PHONY: all install clean
MAKE_EOF

cat > "$SRC_DIR/configure" <<'CONF_EOF'
#!/usr/bin/env bash
# Generated configure script for vmreport 1.0
set -eu

PREFIX="/usr/local"
BINDIR="$PREFIX/bin"
COLOR="yes"

for arg in "$@"; do
  case "$arg" in
    --help)
      cat <<'HELP_EOF'
`configure' configures vmreport 1.0 to adapt to many kinds of systems.

Usage: ./configure [OPTION]...

Installation directories:
  --prefix=PREFIX         install architecture-independent files in PREFIX
                           [/usr/local]
  --bindir=DIR            user executables [EPREFIX/bin]

Optional Features:
  --disable-color         disable ANSI color output (script-friendly)
  --enable-color          enable ANSI color output (default)
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
    --disable-color)
      COLOR="no"
      ;;
    --enable-color)
      COLOR="yes"
      ;;
    *)
      echo "configure: WARNING: unrecognized option: $arg" >&2
      ;;
  esac
done

echo "checking for gcc... $(command -v gcc || command -v cc)"
echo "checking for make... $(command -v make)"
echo "checking whether to enable color output... $COLOR"
echo "checking where to install user executables... $BINDIR"

DEFS=""
if [ "$COLOR" = "yes" ]; then
  DEFS="-DENABLE_COLOR=1"
fi

sed -e "s|@CC@|${CC:-gcc}|" \
    -e "s|@BINDIR@|$BINDIR|" \
    -e "s|@DEFS@|$DEFS|" \
    Makefile.in > Makefile

cat <<SUMMARY_EOF

vmreport 1.0 configuration summary
------------------------------------
  Install binaries to: $BINDIR
  Color output:         $COLOR

Now run 'make' to build, then 'make install' to install.
SUMMARY_EOF
CONF_EOF

chmod +x "$SRC_DIR/configure"

tar czf /tmp/vmreport-1.0.tar.gz -C "$BUILD_ROOT" vmreport-1.0
sudo mv /tmp/vmreport-1.0.tar.gz /tools/vmreport-1.0.tar.gz
sudo chmod 644 /tools/vmreport-1.0.tar.gz

rm -rf "$BUILD_ROOT"
