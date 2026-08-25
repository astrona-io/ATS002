# Solution Walkthrough

All commands below run **inside the `rpmbox` container**. Get a shell first:
```bash
docker exec -it rpmbox bash
mkdir -p /home/candidate/answers
```

---

## Step 1: Search by Keyword

```bash
dnf search fail2ban | tee /home/candidate/answers/search.txt
```
`dnf search` matches package names *and* summary text, so it surfaces relevant hits even without knowing the exact name.

---

## Step 2: Pull Full Metadata, Without Installing

```bash
dnf info httpd | tee /home/candidate/answers/info.txt
```
Purely a read against dnf's repository metadata cache — nothing about the installed package set changes. (`rpm -q httpd` before and after should be unchanged if it wasn't previously installed.)

---

## Step 3: Find What Provides an Uninstalled Command

```bash
dnf provides '*/ip' | tee /home/candidate/answers/provides.txt
```
The `*/ip` glob matches the command name regardless of which directory it ends up in (`/usr/sbin/ip` here) — more robust than guessing an exact path. Expect the answer to point at the `iproute` package.

---

## Step 4: List Installed Packages by Pattern

```bash
dnf list installed | grep '^python3-' | tee /home/candidate/answers/python-packages.txt
```
Anchoring with `^` matches only the start of the package-name column, not any incidental mention of `python3-` elsewhere in the line.

---

## Quick Verification

```bash
cat /home/candidate/answers/search.txt | grep -i fail2ban
cat /home/candidate/answers/info.txt | grep -E '^(Name|Version)'
cat /home/candidate/answers/provides.txt | grep -i iproute
cat /home/candidate/answers/python-packages.txt | grep -c '^python3-'
```
Once you're satisfied, run the local validation suite to pass the lab.
