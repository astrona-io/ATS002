# Solution Walkthrough

Six steps, run in order: the everyday `apt` maintenance loop. Run `astrona submit` after a step to see which checks already pass.

---

## Step 1: Refresh the package index

```bash
sudo apt update
```

This downloads the package index again from every repository listed in `/etc/apt/sources.list` and `/etc/apt/sources.list.d/*`. Nothing installed on the system changes. It only updates APT's knowledge of what is available right now, and at what version. Everything after this step depends on that index being current.

---

## Step 2: Preview what is upgradable, without upgrading

```bash
apt list --upgradable
```

This lists every installed package that has a newer candidate version available, and changes nothing. Each line shows the package name, the new candidate version and, in brackets, the version installed now.

---

## Step 3: Apply the available upgrades

```bash
sudo apt upgrade
```

This installs the newer version of every installed package that *can* be upgraded without also installing or removing another package. If the output ends with a "kept back" list, those packages need the stronger command:

```bash
sudo apt full-upgrade
```

`full-upgrade` (the same operation as `apt-get dist-upgrade`) is willing to add or remove packages to complete an upgrade that plain `upgrade` would not try. Run it only if the kept-back change is expected.

---

## Step 4: Install the newly required package

```bash
sudo apt install fail2ban
```

A plain `apt install` resolves `fail2ban`'s dependencies against the index you refreshed in Step 1 and installs everything needed in one transaction.

At this point `astrona submit` should pass the `fail2ban` check.

---

## Step 5: Purge the unneeded package, including its configuration

```bash
apt list --installed | grep ftp
```

Confirm that it is installed and note the exact package name first.

```bash
sudo apt purge ftp
```

`purge` removes the package's programs *and* the configuration files it tracks under `/etc` (its "conffiles"), leaving a clean slate. `apt remove ftp` would leave `/etc/ftp.conf` behind instead, which is the wrong result when the goal is a clean future reinstall.

---

## Step 6: Clean up orphaned dependencies

```bash
sudo apt autoremove
```

This finds every package that was installed automatically as a dependency, and that nothing installed still needs, and removes it. It is a separate, deliberate step: purging `ftp` never cascades to its orphaned dependencies on its own.

---

## Check

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

When every check looks right, send the lab for grading:

```bash
astrona submit -c sections/section-050/module-03/labs/lab-01
```
