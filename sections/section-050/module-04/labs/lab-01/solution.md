# Solution Walkthrough

Five research questions, all read-only. `/opt/course/apt-research/` already exists and is owned by your user, so none of these commands need `sudo`. Run `astrona submit` after a step to see which checks already pass.

---

## Step 1: Search by keyword, without knowing the exact package name

```bash
apt search fail2ban > /opt/course/apt-research/fail2ban-search.txt
```

`apt search` matches your keyword against both package *names* and their description text, ignoring case. It is the right tool when a task describes what a package does rather than naming it. Saving the full output keeps every hit, not just the first line.

---

## Step 2: Get the full metadata of one package, without installing it

```bash
apt show nginx > /opt/course/apt-research/nginx-show.txt
```

`apt show` prints the package's complete control metadata: version, maintainer, declared dependencies, description, and installed and download size. It reads only the local index cache, so nothing about the installed packages changes.

---

## Step 3: Compare installed and candidate versions, and the source repository

```bash
apt-cache policy nginx > /opt/course/apt-research/nginx-policy.txt
```

The `Installed:` line says whether the package is on the system right now (`(none)` if not). `Candidate:` is the version a plain `apt install` or `apt upgrade` would apply. The indented version table below them shows which repository each version comes from, the detail `apt show` never gives you.

---

## Step 4: List installed packages that match a pattern

```bash
apt list --installed 2>/dev/null | grep '^python3-' > /opt/course/apt-research/python3-installed.txt
```

`apt list --installed` shows installed packages only. The `^` anchor in `grep` matters: it matches only names that *begin with* `python3-`, not any package that has the text somewhere later in its name or version. The `grep` also drops `apt list`'s `Listing...` header line, and `2>/dev/null` hides `apt`'s warning that its output format may change between versions.

---

## Step 5: List everything that is upgradable

```bash
apt list --upgradable 2>/dev/null > /opt/course/apt-research/upgradable.txt
```

This is the same `list` subcommand with a different filter. It is a pure report, not the same as running `apt upgrade`. The file may contain only the `Listing...` line if nothing is upgradable; the grader ignores that line.

---

## Check

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

When every check looks right, send the lab for grading:

```bash
astrona submit -c sections/section-050/module-04/labs/lab-01
```
