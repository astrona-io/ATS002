# Part 2 — Discovering and choosing configure flags

> Prerequisite: [Part 1 — Unpacking the tarball, and the build pipeline](./course-01-unpacking-and-the-build-pipeline.md). Next: [Part 3 — Building, installing, and verifying](./course-03-building-installing-verifying.md).

Because every `configure` script is different, you never guess a flag from memory — you ask the script. This part is `./configure --help`, the two distinct families of flag it lists, and why `--prefix` is the wrong tool when a task names an exact binary path.

## Ask the script

```bash
# shell: inside the extracted source dir, unprivileged
./configure --help
```

This prints every flag *this project's* `configure` accepts: a common Autoconf baseline plus project-specific toggles. When a task gives two unrelated requirements — "install to this exact path" **and** "turn off this feature" — grep for each rather than scrolling:

```bash
./configure --help | grep -i bindir
./configure --help | grep -i ipv6
```

```text
--bindir=DIR            user executables [EPREFIX/bin]
--disable-ipv6          disable IPv6 support
```

## Two families of flag — do not mix them up

The single most common way to lose points on a source-install task is treating a path flag as a feature flag or vice versa.

| Family | Answers | Examples | What it changes |
|---|---|---|---|
| **Installation paths** | *where does the output go?* | `--prefix`, `--exec-prefix`, `--bindir`, `--sbindir`, `--libdir`, `--mandir`, `--datadir`, `--sysconfdir` | which directory files are copied into — nothing about the binary's contents |
| **Feature toggles** | *what code is compiled in?* | `--enable-X` / `--disable-X`, `--with-LIB` / `--without-LIB` | whether a capability exists in the binary at all |

`--disable-ipv6` produces a binary that *cannot* do IPv6 — the code is not in it. `--bindir=/usr/bin` produces the same binary, placed in a specific directory. Different axes entirely.

`--with-X` / `--without-X` usually gate an optional **library** dependency (`--with-ssl`, `--without-zlib`); `--enable-X` / `--disable-X` usually gate a **built-in feature**. Projects are not perfectly consistent — read the `--help` line.

## Why `--prefix` alone is not precise enough

`--prefix` is the flag people reach for first, and it is the wrong one when a task demands an *exact* binary path.

`--prefix` sets the **root** of the whole install tree. Every subdirectory is computed from it:

```
  --prefix=/usr/local            (the default)
        ├── bin/     ← $prefix/bin        the binary lands here
        ├── sbin/    ← $prefix/sbin
        ├── lib/     ← $prefix/lib
        └── share/man/ ← $prefix/share/man
```

So `--prefix=/usr` puts the binary at `/usr/bin/<name-the-project-uses-for-its-own-binary>` — which is **not guaranteed** to be `/usr/bin/links`. The project might name its output `links2` (matching the tarball) unless it explicitly renames it. `--prefix` gets you the right directory only if the project's binary name already matches what you were asked for.

`--bindir` removes that dependency — it pins the exact directory, independent of `--prefix`:

```bash
./configure --bindir=/usr/bin --disable-ipv6
```

Now the binary is copied into `/usr/bin` regardless of what `--prefix` computes. (The *filename* is still the project's choice — Part 3 covers closing that last gap.)

**Rule:** when a task names an exact path for the final binary, use the specific directory flag (`--bindir`, `--sbindir`, `--mandir`) — do not trust `--prefix` to compute it.

> [!WARNING]
> - **Guessing a flag name.** Every `configure` is different; an unknown `--enable-foo` may be silently ignored. `./configure --help | grep` first.
> - **Using `--prefix` when the task names an exact binary path.** `$prefix/bin/<name>` is computed and the `<name>` may not be what you expect. Use `--bindir`.
> - **Confusing `--disable-X` with a path flag.** One removes code, the other moves files. A task that says "without IPv6" wants `--disable-ipv6`, not a directory change.
> - **Assuming `--with-` and `--enable-` are interchangeable.** They usually gate different things (optional library vs built-in feature). Read the help line.

> *`./configure --help` is the only flag reference; it lists path flags (`--prefix`, `--bindir`, …) that decide where files go and feature flags (`--enable/--disable/--with/--without`) that decide what is compiled in — and for an exact binary path use `--bindir`, not `--prefix`.*

## Reference

- `./configure --help` in the source tree — the authoritative, per-project flag list.
- GNU Coding Standards, "Directory Variables" — what every standard `--*dir` flag defaults to and how they derive from `--prefix`/`--exec-prefix`.
- GNU Autoconf manual, "Package Options" vs "Optional Features" — the `--with`/`--without` vs `--enable`/`--disable` conventions.
