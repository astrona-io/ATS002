# Solution Walkthrough

## Step 1: Find the exact file, then inspect it before installing

```bash
ls /home/candidate/downloads/
```

```bash
dpkg -I /home/candidate/downloads/logtail-utils_2.3.1_*.deb
dpkg -c /home/candidate/downloads/logtail-utils_2.3.1_*.deb
```

`-I` (info) reads the embedded control file — package name, version, architecture, maintainer, and any declared dependencies — without touching the installed-package database at all. `-c` (contents) lists every path the archive would place on disk, with permissions and ownership, so nothing about the install is a surprise: a single `/usr/bin/logtail` script and its accompanying doc file, nothing under `/etc` or anywhere unexpected.

---

## Step 2: Install it directly

```bash
sudo dpkg -i /home/candidate/downloads/logtail-utils_2.3.1_*.deb
```

Since this package declares no unmet dependencies, this finishes cleanly. (If it had, the standard reflex is `sudo apt --fix-broken install` immediately afterward — `dpkg` alone has no repository to fetch a missing dependency from.)

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

`-S` (search) is the reverse lookup — file to package. `-L` (listfiles) is the forward lookup — package to files. Both only resolve correctly once the package is genuinely, cleanly installed.

---

## Step 4: Diagnose the unrelated broken package

```bash
dpkg -l | grep cowsay
```

```text
iF  cowsay  3.03+dfsg2-8  all  configure a cow
```

The `iF` status — half-configured — is the fingerprint of an interruption: files are on disk, but the package's post-install configuration step never finished.

---

## Step 5: Recover it

```bash
sudo dpkg --configure -a
```

The `-a`/`--pending` modifier resumes configuration for **every** package left in a pending state, not just the one you happened to notice — the right approach when you don't know the full scope of what an interruption affected.

```bash
sudo apt --fix-broken install
```

Run this safety net immediately after, even if the previous command reported success — it catches a genuinely missing dependency, which `dpkg --configure -a` alone cannot resolve.

---

## Step 6: Verify

```bash
dpkg -l | grep cowsay
```
```text
ii  cowsay  3.03+dfsg2-8  all  configure a cow
```

```bash
sudo dpkg --audit
```
Expected: no output — no package left in any pending/incomplete state anywhere on the system.

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

Once verified, run the local validation suite to pass the lab!
