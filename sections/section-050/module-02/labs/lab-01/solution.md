# Solution Walkthrough

Six steps: inspect, install, check ownership, then diagnose and recover the stuck package. Run `astrona submit` after a step to see which checks already pass.

## Step 1: Find the exact file, then inspect it before installing

```bash
ls /home/candidate/downloads/
```

```bash
dpkg -I /home/candidate/downloads/logtail-utils_2.3.1_*.deb
dpkg -c /home/candidate/downloads/logtail-utils_2.3.1_*.deb
```

`-I` (info) reads the control file inside the `.deb`: package name, version, architecture, maintainer and any declared dependencies. It does not touch the installed-package database at all. `-c` (contents) lists every path the archive would place on disk, with permissions and owner. Here that is a single `/usr/bin/logtail` script and its documentation file, with nothing under `/etc` or anywhere unexpected.

---

## Step 2: Install it directly

```bash
sudo dpkg -i /home/candidate/downloads/logtail-utils_2.3.1_*.deb
```

This package declares no unmet dependencies, so the install finishes cleanly. If it had a missing dependency, the standard habit is to run `sudo apt --fix-broken install` right afterwards, because `dpkg` alone has no repository to fetch it from.

At this point `astrona submit` should pass the install and ownership checks.

---

## Step 3: Confirm ownership in both directions

```bash
dpkg -S /usr/bin/logtail
```
```text
logtail-utils: /usr/bin/logtail
```

```bash
dpkg -L logtail-utils
```
```text
/.
/usr
/usr/bin
/usr/bin/logtail
/usr/share/doc/logtail-utils
/usr/share/doc/logtail-utils/README
...
```

The `dpkg -L` output is shortened. `-S` (search) is the reverse lookup, from file to package. `-L` (listfiles) is the forward lookup, from package to files. Both only answer correctly once the package is fully installed.

---

## Step 4: Diagnose the unrelated broken package

```bash
dpkg -l | grep cowsay
```

```text
iF  cowsay  3.03+dfsg2-8  all  configure a cow
```

The `iF` status (half-configured) is the fingerprint of an interruption: the files are on disk, but the package's post-install configure step never finished.

---

## Step 5: Recover it

```bash
sudo dpkg --configure -a
```

The `-a` (`--pending`) option finishes configuring **every** package left waiting, not just the one you happened to notice. That is the right approach when you do not know everything an interruption touched.

```bash
sudo apt --fix-broken install
```

Run this safety net right after, even if the previous command reported success. It catches a dependency that is really missing, which `dpkg --configure -a` alone cannot fix.

---

## Step 6: Check

```bash
dpkg -l | grep cowsay
```
```text
ii  cowsay  3.03+dfsg2-8  all  configure a cow
```

```bash
sudo dpkg --audit
```

Expected: no output. No package is left in a waiting or incomplete state anywhere on the system.

---

## Command Summary

```bash
ls /home/candidate/downloads/
dpkg -I /home/candidate/downloads/logtail-utils_2.3.1_*.deb
dpkg -c /home/candidate/downloads/logtail-utils_2.3.1_*.deb
sudo dpkg -i /home/candidate/downloads/logtail-utils_2.3.1_*.deb

dpkg -S /usr/bin/logtail
dpkg -L logtail-utils

dpkg -l | grep cowsay
sudo dpkg --configure -a
sudo apt --fix-broken install
dpkg -l | grep cowsay
```

When every check looks right, send the lab for grading:

```bash
astrona submit -c sections/section-050/module-02/labs/lab-01
```
