# Solution Guide: Zypper Basic Package Operations

This guide walks through a realistic maintenance pass with real `zypper` commands, run inside the `zypperbox` openSUSE Leap 15.6 container. The grader looks at the container's real state: whether `fail2ban` and `telnet-server` are installed, and what `/var/log/zypp/history` recorded.

---

## Step 0: Enter the zypperbox container

```bash
docker exec -it zypperbox bash
```

Every command from here on runs inside this shell, not on the Ubuntu host. Docker opens the shell as root, so you do not need `sudo` inside it. If Docker refuses with a permission error on the host, run the same command with `sudo` in front.

---

## Step 1: Refresh repository metadata

```bash
zypper refresh
```

`zypper` downloads a fresh copy of each configured repository's metadata: the package versions and the patch definitions it offers. Nothing installed on the system changes. It only updates what `zypper` *knows* is available.

---

## Step 2: Check raw updates and patches separately

```bash
zypper list-updates
```

This lists every installed package that has a newer version available. It is a plain comparison of version numbers.

```bash
zypper list-patches
```

This lists SUSE's patch objects: named, tracked bundles that a maintainer reviewed and published, often to fix one known security flaw. Each one has a category and a severity. The two commands answer different questions, so a package can appear in one list and not in the other.

---

## Step 3: Apply only patches, as the conservative policy requires

```bash
zypper patch
```

This applies only the updates that a currently published patch covers. Any newer version that no patch covers is left alone, which is the conservative choice this host's policy asks for. Running `zypper update` instead would apply every available update, patch or not, which is more change than the policy allows.

To limit it further to security patches only:

```bash
zypper patch --category security
```

---

## Step 4: Install the newly required package

```bash
zypper install fail2ban
```

The short form works too: `zypper in fail2ban`. `zypper` works out the dependencies, and the RPM layer underneath unpacks the files and records the package in the RPM database.

---

## Step 5: Remove the unneeded package

```bash
zypper search --installed-only telnet-server
zypper remove telnet-server
```

First confirm the package really is installed, then remove it. The real openSUSE package name is `telnet-server`. It is the package that provides the `telnetd` daemon program; there is no package literally called `telnetd`. The short form works too: `zypper rm telnet-server`.

As with any RPM removal, configuration files the package shipped and nobody changed are deleted. Any you had edited would be kept with an `.rpmsave` ending.

---

## Step 6: Review zypper's operation log

```bash
zypper history
```

Check the end of the log to confirm that the patch run, the `fail2ban` install and the `telnet-server` removal all appear, each with a timestamp, in the order they ran:

```bash
zypper history | tail -10
```

If your `zypper` answers that `history` is an unknown command, read the log file directly with `tail -n 10 /var/log/zypp/history`. That file is what the grader reads.

Remember what this log is *not*: it is an audit trail, not a rollback tool like `dnf history undo`. There is no `zypper history undo`.

---

## Verification

```bash
rpm -q fail2ban
```
Expected: a version string, which confirms the package is installed.

```bash
rpm -q telnet-server
```
Expected: `package telnet-server is not installed`, which confirms the removal.

```bash
zypper history | tail -10
```
Expected: log entries for the patch run, the `fail2ban` install and the `telnet-server` removal, in that order.

Then leave the container with `exit` and send the lab for grading with `astrona submit -c sections/section-070/module-01/labs/lab-01`.
