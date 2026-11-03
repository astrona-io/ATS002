# Solution Walkthrough

Two separate tasks: one install transaction, then a bulk hold found by pattern. Run `astrona submit` after a step to see which checks already pass.

---

## Step 1: Install the toolchain as one transaction

```bash
sudo apt install build-essential git cmake pkg-config
```

Giving all four names to one command means APT plans the dependencies of all four together. It finds one set of versions that suits all four at once, instead of four separate plans run one after another. `build-essential` is a metapackage: it has no real content of its own and exists only to pull in `gcc`, `g++`, `make` and the rest of a standard build toolchain as dependencies. It installs exactly like any other package name.

At this point `astrona submit` should pass the toolchain check.

---

## Step 2: Find every installed package that matches the PHP 8.1 pattern

```bash
apt list --installed 2>/dev/null | grep -E '^php8\.1-'
```

Two details matter here, and they are not just style. `-E` (extended regular expression) lets the literal dot in `8.1` be written as `\.`. Without the escape, a `.` matches *any* character, which is wrong for a version number. The `^` anchor limits the match to the *start* of the package name, so nothing that only mentions `php8.1-` later in a longer name or a version string is swept in.

---

## Step 3: Extract clean package names

```bash
apt list --installed 2>/dev/null | grep -E '^php8\.1-' | cut -d/ -f1
```

`apt list` puts a `/` right after the package name. `cut -d/ -f1` keeps exactly that name, which is what `apt-mark hold` needs as its arguments, not the full descriptive line.

---

## Step 4: Hold the whole matched family in one call

```bash
apt list --installed 2>/dev/null | grep -E '^php8\.1-' | cut -d/ -f1 | xargs sudo apt-mark hold
```

`apt-mark hold` accepts any number of package names in one call, and `xargs` supplies them. Every matched name becomes one argument of a single command, so the whole family is held in one action instead of a loop that holds one package at a time.

Holding the entire family matters. If these packages depend on each other (built against the same PHP minor version), holding only some lets the unheld ones move to a newer PHP release while the held ones stay behind. That leaves a mismatched installation that only *looks* protected.

---

## Step 5: Check the resulting hold list

```bash
apt-mark showhold
```

Compare this line for line with the output of Step 3. Do not just trust that the pipeline in Step 4 "probably worked" because it showed no error: confirm that the real hold set matches what you meant.

---

## Command Summary

```bash
sudo apt install build-essential git cmake pkg-config

apt list --installed 2>/dev/null | grep -E '^php8\.1-'
apt list --installed 2>/dev/null | grep -E '^php8\.1-' | cut -d/ -f1 | xargs sudo apt-mark hold

apt-mark showhold
```

When every check looks right, send the lab for grading:

```bash
astrona submit -c sections/section-050/module-05/labs/lab-01
```
