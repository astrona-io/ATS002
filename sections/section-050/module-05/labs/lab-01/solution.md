# Solution Walkthrough

Two independent tasks: one atomic install, then a pattern-matched bulk hold.

---

## Step 1: Install the toolchain as one transaction

```bash
sudo apt install build-essential git cmake pkg-config
```

Passing all four names in a single invocation means APT resolves every one of their dependencies together, computing one consistent version set that satisfies all four simultaneously — not four independent resolutions run back to back. `build-essential` is a meta-package: it carries no real payload of its own, existing purely to pull in `gcc`, `g++`, `make`, and the rest of a standard build toolchain as dependencies. It installs exactly like any other package name here.

---

## Step 2: Find every installed package matching the PHP 8.1 pattern

```bash
apt list --installed 2>/dev/null | grep -E '^php8\.1-'
```

Two details matter here, not just style. `-E` (extended regex) lets the literal dot in `8.1` be escaped as `\.` — without it, an unescaped `.` in basic regex matches *any* character, which is wrong for a version number. Anchoring with `^` restricts the match to the *start* of the package-name field, so nothing that merely mentions `php8.1-` later in a longer name or version string gets swept in by accident.

---

## Step 3: Extract clean package names

```bash
apt list --installed 2>/dev/null | grep -E '^php8\.1-' | cut -d/ -f1
```

`apt list`'s output puts a `/` immediately after the package name — `cut -d/ -f1` isolates exactly that, which is what `apt-mark hold` needs as its arguments, not the full descriptive line.

---

## Step 4: Bulk-hold the entire matched family in one call

```bash
apt list --installed 2>/dev/null | grep -E '^php8\.1-' | cut -d/ -f1 | xargs sudo apt-mark hold
```

`apt-mark hold` accepts any number of package names in one invocation, which is exactly what `xargs` supplies — every matched name becomes one argument in a single consolidated call, holding the whole family together in one action rather than looping and holding one package at a time.

Holding the entire family matters, not just a couple of named packages: if these packages share real interdependencies (built against the same PHP ABI/minor version), holding only some of them lets the unheld ones drift to a newer PHP release while the held ones stay behind — a mismatched, inconsistent installation that only *looks* protected.

---

## Step 5: Audit the resulting hold list

```bash
apt-mark showhold
```

Compare this line-for-line against Step 3's output. Don't just trust that Step 4's pipeline "probably worked" because it didn't error — confirm the actual resulting hold set matches what was intended.

---

## Command Summary

```bash
sudo apt install build-essential git cmake pkg-config

apt list --installed 2>/dev/null | grep -E '^php8\.1-'
apt list --installed 2>/dev/null | grep -E '^php8\.1-' | cut -d/ -f1 | xargs sudo apt-mark hold

apt-mark showhold
```

Once verified, run the local validation suite to pass the lab!
