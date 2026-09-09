# Solution Guide: Section 070 Capstone — Zypper Research and Action

This capstone ties together both module skill sets: research a package thoroughly before touching the system (module 2), then act on that research with real install/remove/patch operations (module 1) — all inside the real openSUSE Leap 15.6 `zypperbox` container.

---

## Step 0: Enter the zypperbox Container

```bash
docker exec -it zypperbox bash
```

Every command from here on runs inside this shell, not on the Ubuntu host. Bootstrap has already created `/root/answers` for your research findings.

---

## Step 1: Refresh repository metadata

```bash
zypper refresh
```

Re-syncs zypper's local cache of package and patch metadata for every configured repository, including the `network-utilities` repo bootstrap already added for `telnet-server`. Nothing installed changes as a result.

---

## Step 2: Research the first change — keyword search

```bash
zypper search fail2ban | tee /root/answers/01-research-search.txt
```

A functional keyword like "fail2ban," "ban," or "intrusion" surfaces the right candidate via `zypper search`'s name-and-summary scan, without needing to already know the exact package name.

---

## Step 3: Confirm before installing — full metadata

```bash
zypper info fail2ban | tee /root/answers/02-research-info.txt
```

`zypper info` prints the candidate's full metadata — version, size, summary — without installing anything, letting you confirm it's genuinely the right package before committing to an install.

---

## Step 4: Research the second change — confirm before removing

```bash
zypper search --installed-only telnet-server | tee /root/answers/03-confirm-telnet-installed.txt
```

Confirms `telnet-server` is actually present on this host, via zypper's own installed-only filter, rather than assuming based on the request alone.

---

## Step 5: Apply the conservative patch policy

```bash
zypper patch
```

Applies only currently available curated patch definitions — the conservative choice for a security-focused policy — leaving any raw version bump not covered by a published patch untouched. `zypper update` would apply more than this policy calls for.

---

## Step 6: Act on the research — install and remove

```bash
zypper install fail2ban
zypper remove telnet-server
```

Both actions are now informed by the research already done in Steps 2–4, not guesswork.

---

## Step 7: Review the operation history

```bash
zypper history | tail -15
```

Confirms the patch application, the `fail2ban` install, and the `telnet-server` removal all landed, timestamped in the order they actually ran. Remember: this is an audit log, not a `dnf history undo`-style rollback mechanism.

---

## Verification

```bash
cat /root/answers/01-research-search.txt
```
Expected: a row naming `fail2ban`.

```bash
cat /root/answers/02-research-info.txt
```
Expected: full `fail2ban` metadata, including a `Version` field.

```bash
cat /root/answers/03-confirm-telnet-installed.txt
```
Expected: a row for `telnet-server` marked `i` (installed) in the status column.

```bash
rpm -q fail2ban
```
Expected: a version string confirming installation.

```bash
rpm -q telnet-server
```
Expected: `package telnet-server is not installed` — confirms removal.

```bash
zypper history | tail -15
```
Expected: the `fail2ban` install entry appears, followed later by the `telnet-server` removal entry, matching the order the maintenance window was actually performed in.
