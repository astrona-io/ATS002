# Solution Walkthrough

Six steps, run in order — the everyday `apt` maintenance loop.

---

## Step 1: Refresh the package index

```bash
sudo apt update
```

This re-syncs the local package index against every repository listed in `/etc/apt/sources.list` and `/etc/apt/sources.list.d/*`. Nothing installed on the system changes — this only updates APT's knowledge of what's currently available and at what version. Everything after this step depends on this index being current.

---

## Step 2: Preview what's upgradable, without upgrading

```bash
apt list --upgradable
```

This lists every installed package with a newer candidate version now available, changing nothing in the process. Each line shows the package name, the new candidate version, and (in brackets) the currently installed version.

---

## Step 3: Apply the available upgrades

```bash
sudo apt upgrade
```

This installs the newer version of every currently-installed package that *can* be upgraded without also installing or removing some other package. If the output ends with a "kept back" list, those specific packages need the more aggressive:

```bash
sudo apt full-upgrade
```

`full-upgrade` (the same operation as `apt-get dist-upgrade`) is willing to add or remove packages to complete an upgrade plain `upgrade` wouldn't attempt on its own.

---

## Step 4: Install the newly required package

```bash
sudo apt install fail2ban
```

A plain `apt install` resolves `fail2ban`'s dependencies against the index refreshed in Step 1 and installs everything needed in one transaction.

---

## Step 5: Fully purge the unneeded package, including config

```bash
apt list --installed | grep ftp
```

Confirm it's actually installed and note the exact package name first.

```bash
sudo apt purge ftp
```

`purge` removes both the package's binaries *and* any configuration files it left under `/etc` (its "conffiles") — a genuinely clean slate. `apt remove ftp` here instead would leave `/etc/ftp.conf` behind, which is the wrong outcome when the goal is a clean future reinstall.

---

## Step 6: Clean up now-orphaned dependencies

```bash
sudo apt autoremove
```

This identifies every package that was installed automatically as a dependency of something now gone, and that nothing currently installed still depends on, and removes it. This is a separate, deliberate follow-up — purging `ftp` itself never automatically cascades to its orphaned dependencies without this explicit step.

---

## Verify

```bash
apt list --upgradable
# expected: empty (or only deliberately held/kept-back packages)

dpkg -s fail2ban | grep Status
# Status: install ok installed

dpkg -s ftp 2>&1
# dpkg-query: package 'ftp' is not installed and no information is available

ls /etc/ftp* 2>/dev/null; echo "exit code: $?"
# no matching files, non-zero exit code

apt autoremove --dry-run
# 0 to remove
```

---

## Command Summary

```bash
sudo apt update
apt list --upgradable
sudo apt upgrade
sudo apt full-upgrade      # only if packages were kept back, and that's expected/safe

sudo apt install fail2ban

apt list --installed | grep ftp
sudo apt purge ftp
sudo apt autoremove
```

Once verified, run the local validation suite to pass the lab!
