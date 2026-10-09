# Solution Walkthrough

This walkthrough builds `links` from its source tarball and installs it at one exact path with one feature switched off. After each step you can run `astrona submit` from your own computer to see how far the grader agrees. It only passes once the last check is green.

---

## Step 1: Extract the source tarball

```bash
cd /tools
tar xjf links-2.14.tar.bz2
cd links-2.14
```

`-x` extracts, `-f` names the archive file, and `-j` picks bzip2 decompression, which a `.tar.bz2` archive needs. For a `.tar.gz` archive you would use `-z` instead.

The `/tools` folder belongs to root. If `tar` reports "Permission denied" because your user cannot write there, run the `tar` command with `sudo`, or unpack it into your home folder with `tar xjf /tools/links-2.14.tar.bz2 -C ~` and `cd ~/links-2.14`. The build works the same from either place.

---

## Step 2: Discover the available configure flags

```bash
./configure --help
```

A `configure` script belongs to its project, so there is no manual page for it. Its own `--help` output is the real reference. Narrow it down with `grep`:

```bash
./configure --help | grep -i bindir
./configure --help | grep -i ipv6
```

```
--bindir=DIR            user executables [EPREFIX/bin]
--disable-ipv6          disable IPv6 support
```

This output is shortened. On the lab machine the second search also shows the line for `--enable-ipv6`, the default you are switching off.

---

## Step 3: Run configure with both requirements

```bash
./configure --bindir=/usr/bin --disable-ipv6
```

`--bindir=/usr/bin` sets the exact folder the task wants. `--prefix=/usr` alone would only promise `$prefix/bin`, which is not enough if the binary's own name does not already match. `--disable-ipv6` is the feature switch you found in Step 2.

Look at the summary near the end of the output. It repeats the chosen install folder and the feature switch before you start the build:

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

`make` builds the program from the `Makefile` that `./configure` just wrote. `make install` copies the built binary into place. It runs with `sudo` because it writes into `/usr/bin`, which belongs to root.

Now run `astrona submit -c sections/section-030/module-01/labs/lab-01` from your own computer. The checks should pass.

---

## Step 5: Confirm the installed binary is named `links`

```bash
ls -l /usr/bin/links
which links
```

`--bindir` sets the folder, not the file name. If the build had installed the program under another name (for example `links2`), you would need `sudo mv /usr/bin/links2 /usr/bin/links`. Check first: this source tree already builds and installs a binary named `links`, so no rename is needed.

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

The `-version` output is the real proof that `--disable-ipv6` took effect at build time. Do not stop at "I passed the flag": confirm that the built program says so too.

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
