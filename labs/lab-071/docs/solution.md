# Solution Guide: Zypper Basic Package Operations

This guide walks a realistic maintenance pass using real zypper commands, executed inside the `zypperbox` openSUSE Leap 15.6 container.

---

## Step 0: Enter the zypperbox Container

```bash
docker exec -it zypperbox bash
```

Every command from here on runs inside this shell, not on the Ubuntu host.

---

## Step 1: Refresh repository metadata

```bash
zypper refresh
```

This re-syncs zypper's local cache of every configured repository's package and patch metadata. Nothing installed on the system changes as a result — it only updates what zypper *knows* is available.

---

## Step 2: Check raw updates and curated patches separately

```bash
zypper list-updates
```

Lists every installed package with a newer version available — a plain version comparison.

```bash
zypper list-patches
```

Lists SUSE's curated patch objects — named, tracked bundles (often addressing specific CVEs), each classified by category and severity. These two commands answer genuinely different questions; a package can appear in one list without appearing in the other.

---

## Step 3: Apply only patches, per the conservative policy

```bash
zypper patch
```

This applies only the updates covered by currently available patch definitions, leaving any raw version bump not covered by a published patch untouched — the deliberate, conservative choice matching this host's policy. Running `zypper update` instead would apply every available update regardless of patch coverage, a more aggressive outcome than the policy calls for.

To restrict further to only security-classified patches:

```bash
zypper patch --category security
```

---

## Step 4: Install the newly required package

```bash
zypper install fail2ban
```

The `in` shorthand alias also works: `zypper in fail2ban`.

---

## Step 5: Remove the unneeded package

```bash
zypper search --installed-only telnet-server
zypper remove telnet-server
```

Confirm it's actually installed first, then remove it. Note the real openSUSE package name is `telnet-server` — it's the package that provides the `telnetd` daemon binary, not a package literally named `telnetd`. The `rm` shorthand also works: `zypper rm telnet-server`. As with any RPM-based removal, unmodified config files this package shipped are deleted; locally modified ones would be preserved with an `.rpmsave`-style suffix.

---

## Step 6: Review zypper's operation log

```bash
zypper history
```

Check the tail of the log to confirm the patch application, the `fail2ban` install, and the `telnet-server` removal all appear, timestamped in the order they actually ran:

```bash
zypper history | tail -10
```

Note what this log is *not*: an audit trail, not a `dnf history undo`-style rollback mechanism. There is no `zypper history undo`.

---

## Verification

```bash
rpm -q fail2ban
```
Expected: a version string confirming installation.

```bash
rpm -q telnet-server
```
Expected: `package telnet-server is not installed` — confirms removal.

```bash
zypper history | tail -10
```
Expected: log entries reflecting the patch application, the `fail2ban` install, and the `telnet-server` removal, in order.
