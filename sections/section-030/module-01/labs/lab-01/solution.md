# Solution Guide: Compile & Install From Source

This guide shows you how to build and install `links` from a source tarball, landing the binary at an exact path with a feature explicitly disabled.

---

## Step 1: Extract the source tarball

```bash
cd /tools
tar xjf links-2.14.tar.bz2
cd links-2.14
```

`-x` extracts, `-f` names the archive file, and `-j` selects bzip2 decompression — required for a `.tar.bz2` archive (use `-z` instead for `.tar.gz`).

---

## Step 2: Discover the available configure flags

```bash
./configure --help
```

There's no `man` page for a project-specific `configure` script — its own `--help` output is the actual reference. Narrow it down with grep:

```bash
./configure --help | grep -i bindir
./configure --help | grep -i ipv6
```

```
--bindir=DIR            user executables [EPREFIX/bin]
--disable-ipv6          disable IPv6 support
```

---

## Step 3: Run configure with both requirements

```bash
./configure --bindir=/usr/bin --disable-ipv6
```

`--bindir=/usr/bin` pins the exact install directory the task wants — `--prefix=/usr` alone would only guarantee `$prefix/bin`, which isn't precise enough if the binary's own build-time name doesn't already match what's wanted. `--disable-ipv6` is the feature flag discovered in Step 2.

Watch the configure summary near the end of its output — it recaps the chosen install path and feature toggle before you commit to the build:

```
links 2.14 configuration summary
---------------------------------
  Install binaries to: /usr/bin
  IPv6 support:         no
```

---

## Step 4: Build and install

```bash
make
sudo make install
```

`make` compiles the source against the `Makefile` that `./configure` just generated. `make install` (run with `sudo`, since it writes into `/usr/bin`) copies the built binary into place.

---

## Step 5: Confirm the installed binary is named `links`

```bash
ls -l /usr/bin/links
which links
```

If the build had installed under a different name (e.g. `links2`), `--bindir` alone would not have renamed it — a `sudo mv /usr/bin/links2 /usr/bin/links` would be needed. Check first: this source tree already builds and installs a binary literally named `links`.

---

## Verification

```bash
which links
# /usr/bin/links

file /usr/bin/links
# /usr/bin/links: ELF 64-bit LSB executable, ...

links -version
# links 2.14 (compiled from source)
# Features: ipv6=disabled
```

The `-version` output is the authoritative proof that the `--disable-ipv6` flag actually took effect at build time — don't stop at "I passed the flag," confirm the built artifact reflects it.

## Command Summary

```bash
cd /tools
tar xjf links-2.14.tar.bz2
cd links-2.14
./configure --help | grep -i bindir
./configure --help | grep -i ipv6
./configure --bindir=/usr/bin --disable-ipv6
make
sudo make install
which links
file /usr/bin/links
links -version
```
