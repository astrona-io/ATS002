# Solution Guide: Zypper Package Information Lookup

This guide walks four real zypper research tasks, executed inside the `zypperbox` openSUSE Leap 15.6 container. Nothing gets installed, removed, or changed anywhere along the way — every command here is read-only.

---

## Step 0: Enter the zypperbox Container

```bash
docker exec -it zypperbox bash
```

Every command from here on runs inside this shell, not on the Ubuntu host. Bootstrap has already created `/root/answers` for you to save each finding into.

---

## Step 1: Keyword search — "I don't know the exact name"

```bash
zypper search fail2ban | tee /root/answers/01-search.txt
```

`zypper search` (shorthand `zypper se`) scans both package names and their summary/description text, case-insensitively. A rough functional keyword like "fail2ban," "ban," or "intrusion" surfaces the package even without knowing its exact name in advance. The leading `S` column shows at a glance whether each hit is already installed — here it should show blank, since fail2ban was never installed in this lab.

---

## Step 2: Full metadata for one exact package, without installing it

```bash
zypper info nginx | tee /root/answers/02-info.txt
```

`zypper info` only matches the exact, literal package name — no partial or description matching the way `search` does. It prints version, architecture, vendor, installed size, repository source, and description, purely from zypper's cached repository metadata. Running it changes nothing about what's installed; the `Installed` field in the output should read `No`.

---

## Step 3: What provides a missing command

```bash
zypper what-provides /usr/sbin/ip | tee /root/answers/03-what-provides.txt
```

`zypper what-provides` searches configured repositories' published metadata for any package that declares it would place a file at that exact path — regardless of whether it's currently installed. The result should name `iproute2` as the owning package. This is zypper's direct analog of `dnf provides`.

---

## Step 4: Filtered installed-only listing

```bash
zypper search --installed-only 'python3-*' | tee /root/answers/04-installed-python3.txt
# shorthand: zypper se -i 'python3-*'
```

The `-i`/`--installed-only` flag restricts results to packages that are both a pattern match **and** currently installed, in a single zypper-native command — bootstrap seeded `python3-base` and `python3-pip` as installed specifically so this step has real, concrete results. Both should appear here with an `i` in the leading status column.

---

## Verification

```bash
cat /root/answers/01-search.txt
```
Expected: a row naming `fail2ban`.

```bash
cat /root/answers/02-info.txt
```
Expected: full metadata for `nginx`, including `Installed : No`.

```bash
cat /root/answers/03-what-provides.txt
```
Expected: a row naming `iproute2`.

```bash
cat /root/answers/04-installed-python3.txt
```
Expected: rows for `python3-base` and `python3-pip`, each marked `i` (installed) in the status column.

```bash
rpm -q nginx fail2ban 2>&1
```
Expected: both report "package ... is not installed" — confirming this lab stayed entirely read-only.
