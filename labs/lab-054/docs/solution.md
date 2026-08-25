# Solution Walkthrough

Five research questions, all read-only. `/opt/course/apt-research/` already exists and is owned by your user, so none of these need `sudo`.

---

## Step 1: Search by keyword, without knowing the exact package name

```bash
apt search fail2ban > /opt/course/apt-research/fail2ban-search.txt
```

`apt search` matches your keyword against both package *names* and their description text, case-insensitively — the right tool when a task describes functionality rather than an exact package name. Saving the full output preserves every hit, not just the first line.

---

## Step 2: Pull full metadata for a specific package, without installing it

```bash
apt show nginx > /opt/course/apt-research/nginx-show.txt
```

`apt show` prints the package's complete control-file metadata — version, maintainer, declared dependencies, description, installed/download size — sourced entirely from the local index cache. Nothing about the installed package set changes as a result.

---

## Step 3: Confirm installed vs. candidate version and source repository

```bash
apt-cache policy nginx > /opt/course/apt-research/nginx-policy.txt
```

The `Installed:` line answers whether it's on the system right now (or `(none)` if not); `Candidate:` is the version a plain `apt install`/`apt upgrade` would apply. The indented version table beneath both shows exactly which repository each competing source line comes from — the detail `apt show` alone never reveals.

---

## Step 4: List installed packages matching a pattern

```bash
apt list --installed 2>/dev/null | grep '^python3-' > /opt/course/apt-research/python3-installed.txt
```

`apt list --installed` restricts output to currently-installed packages only. Anchoring the `grep` with `^` matters — it matches only names that *begin with* `python3-`, not any package that merely mentions the string somewhere later in its name or version. `2>/dev/null` discards `apt list`'s harmless "Listing..." status line so it doesn't leak into the saved file.

---

## Step 5: List everything currently upgradable

```bash
apt list --upgradable 2>/dev/null > /opt/course/apt-research/upgradable.txt
```

Same `list` subcommand, different filter — a pure reporting step, distinct from actually running `apt upgrade`.

---

## Verify

```bash
cat /opt/course/apt-research/fail2ban-search.txt
cat /opt/course/apt-research/nginx-show.txt | grep -E '^(Package|Version):'
cat /opt/course/apt-research/nginx-policy.txt
cat /opt/course/apt-research/python3-installed.txt
cat /opt/course/apt-research/upgradable.txt
```

---

## Command Summary

```bash
apt search fail2ban > /opt/course/apt-research/fail2ban-search.txt
apt show nginx > /opt/course/apt-research/nginx-show.txt
apt-cache policy nginx > /opt/course/apt-research/nginx-policy.txt
apt list --installed 2>/dev/null | grep '^python3-' > /opt/course/apt-research/python3-installed.txt
apt list --upgradable 2>/dev/null > /opt/course/apt-research/upgradable.txt
```

Once verified, run the local validation suite to pass the lab!
