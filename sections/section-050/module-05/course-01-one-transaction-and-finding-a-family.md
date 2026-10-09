# One Transaction And Finding A Family

Package work rarely happens one package at a time. This part covers installing several related packages as one consistent transaction, and finding a whole family by its naming pattern without listing the packages by hand. Two small pattern details quietly make or break that match.

## Install several as one transaction

Give every related package to one `apt install` call:

```bash
# shell: host, root
sudo apt install build-essential git cmake pkg-config
```

`build-essential` is a **metapackage**: an empty crate whose only job is to pull in other crates. It has no content of its own and exists to bring in `gcc`, `g++`, `make`, `libc6-dev` and the rest of a standard build toolchain as dependencies. It installs like any other name; "meta" changes nothing about the command.

Why one call and not four? `apt` works out the dependencies of **all** named packages **together**, as one **transaction**: one planned change that finds a single set of versions that suits every package at once. Four separate `apt install` calls each plan on their own, at whatever moment they run. That is more fragile if the system changes between calls, and slower. "Install X together with Y and Z" is a direct instruction: one command.

## Find a family by pattern

Imagine a host with a full PHP 8.1 module set: `php8.1-cli`, `php8.1-fpm`, `php8.1-mysql`, `php8.1-curl` and more. You need every one of them:

```bash
apt list --installed | grep -E '^php8\.1-'
```

Two details carry the weight here; they are not style:

- **`-E` (extended regular expression)** lets `\.` cleanly stand for the literal dot in `8.1`. A regular expression is a text pattern, and in it an unescaped `.` matches *any* character. Without the escape, `php8x1-` or `php801-` would match too, which is wrong for a version number.
- **The `^` anchor** limits the match to the **start** of the line, that is the start of the package name. Without it, a package that merely mentions `php8.1-` later in a longer name, or in a version string, gets swept in.

Drop either one and the matched set is silently wrong.

## Strip to clean names

`apt list` output looks like `name/repo,now version arch [installed]`. It is made for reading, not for passing to another command. The package name is always followed directly by a `/`, so cut there:

```bash
apt list --installed 2>/dev/null | grep -E '^php8\.1-' | cut -d/ -f1
```

```text
php8.1-cli
php8.1-curl
php8.1-fpm
php8.1-mysql
```

`cut -d/ -f1` splits each line at `/` and keeps the first field, the bare name. The `2>/dev/null` hides `apt`'s warning that its output format may change between versions. These clean names are exactly what `apt-mark` and other package commands take as arguments.

## Common pitfalls

> [!WARNING]
> - **Four `apt install` calls instead of one.** Each call plans its dependencies on its own, which is fragile if the system changes in between. Give all names to one call.
> - **`grep 'php8.1-'` without `-E` and `^`.** The unescaped `.` matches any character, and the missing anchor matches in the middle of a line. Use `grep -E '^php8\.1-'`.
> - **Feeding `apt list` output straight to `apt-mark`.** The `name/repo,...` suffix breaks it. Run `cut -d/ -f1` first.
