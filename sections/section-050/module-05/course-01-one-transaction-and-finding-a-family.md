# Part 1 — One transaction, and finding a family by pattern

> Prerequisite: [module landing page](./course.md). Next: [Part 2 — Bulk actions across a matched set](./course-02-bulk-actions-across-a-set.md).

Package management rarely happens one package at a time. This part is installing several related packages as one consistent transaction, and finding an entire family by naming pattern without listing packages by hand — including the two regex details that quietly make or break the match.

## Install several as one transaction

```bash
# shell: host, root
sudo apt install build-essential git cmake pkg-config
```

`build-essential` is a **meta-package** — no payload of its own, existing only to pull in `gcc`, `g++`, `make`, `libc6-dev`, and the rest of a standard toolchain as dependencies. It installs like any other name; "meta" changes nothing about the command.

Why one call and not four: APT resolves **all** named packages' dependencies **together**, computing one version set that satisfies every one of them simultaneously. Four separate `apt install` calls each resolve independently, at whatever moment they run — more fragile if system state shifts between calls, and slower. "Install X together with Y and Z" is a direct instruction: one command.

## Find a family by pattern

A host has a full PHP 8.1 module set — `php8.1-cli`, `php8.1-fpm`, `php8.1-mysql`, `php8.1-curl`, more — and you need every one:

```bash
apt list --installed | grep -E '^php8\.1-'
```

Two details are load-bearing, not stylistic:

- **`-E` (extended regex)** so `\.` cleanly escapes the literal dot in `8.1`. Without `-E`, in basic regex an unescaped `.` matches *any* character — `php8x1-`, `php801-` would match too. Wrong for a version number.
- **`^` anchor** so the match is restricted to the **start** of the package-name field. Without it, a package that merely mentions `php8.1-` later in a longer name or in a version string gets swept in.

Drop either and the match set is silently wrong.

## Strip to clean names

`apt list` output is `name/repo,now version arch [installed]` — for reading, not for use as arguments. The package name is always followed immediately by `/`:

```bash
apt list --installed 2>/dev/null | grep -E '^php8\.1-' | cut -d/ -f1
```

```text
php8.1-cli
php8.1-curl
php8.1-fpm
php8.1-mysql
```

`cut -d/ -f1` isolates exactly the field the next command needs (Part 2).

> [!WARNING]
> - **Four `apt install` calls instead of one** → dependencies resolved independently; fragile if state shifts between calls. Pass all names to one call.
> - **`grep 'php8.1-'` (no `-E`, no `^`)** → the unescaped `.` matches any character and the missing anchor matches mid-string. Use `grep -E '^php8\.1-'`.
> - **Feeding `apt list` output straight to `apt-mark`** → the `name/repo,...` suffix breaks it. `cut -d/ -f1` first.

> *Pass every related package to a single `apt install` so their dependencies resolve as one set; find a family with `grep -E '^prefix'` (the `-E` escapes the literal dot, the `^` anchors to the name start) and `cut -d/ -f1` to get clean names.*

## Reference

- `man apt` — `install` with multiple names; meta-packages behave like any package.
- `man 1 grep` — `-E` extended regex, anchoring; why an unescaped `.` is a wildcard.
- `man 1 cut` — `-d` / `-f` for field extraction from `apt list` output.
