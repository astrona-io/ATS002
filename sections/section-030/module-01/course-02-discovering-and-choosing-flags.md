# Discovering And Choosing Configure Flags

Astronaut, every kit of parts comes with its own fitting plan, and no two plans take the same options. So you never guess a `configure` flag from memory. You ask the script itself. This part shows how to ask with `./configure --help`, the two kinds of flag it lists, and why `--prefix` is the wrong tool when a task names an exact path for the binary.

## Ask the script

A **flag** is an option you pass to a command, such as `--bindir=/usr/bin`. A `configure` script prints every flag it accepts when you run it with `--help`.

### Read the help, then filter it

Run this inside the unpacked source folder:

```bash
# shell: inside the extracted source dir, unprivileged
./configure --help
```

This prints every flag that *this project's* `configure` accepts. You get a common Autoconf base set plus the switches this project adds. A task often has two separate requirements, such as "install to this exact path" **and** "turn off this feature". Search for each one with `grep` instead of scrolling:

```bash
./configure --help | grep -i bindir
./configure --help | grep -i ipv6
```

```text
--bindir=DIR            user executables [EPREFIX/bin]
--disable-ipv6          disable IPv6 support
```

This output is shortened: a real help text often lists the matching `--enable-ipv6` line too. The first line is a path flag. The second line switches off IPv6 (Internet Protocol version 6, the newer form of network address) in the built program.

## Two families of flag — do not mix them up

The most common way to lose points on a source install is to treat a path flag as a feature flag, or the other way round. The table puts the two families side by side.

| Family | Answers | Examples | What it changes |
|---|---|---|---|
| **Installation paths** | *where does the output go?* | `--prefix`, `--exec-prefix`, `--bindir`, `--sbindir`, `--libdir`, `--mandir`, `--datadir`, `--sysconfdir` | which directory files are copied into — nothing about the binary's contents |
| **Feature toggles** | *what code is compiled in?* | `--enable-X` / `--disable-X`, `--with-LIB` / `--without-LIB` | whether a capability exists in the binary at all |

`--disable-ipv6` builds a binary that *cannot* use IPv6, because that code is not in it. `--bindir=/usr/bin` builds the same binary as before and only places it in a different folder. These are two different questions.

`--with-X` and `--without-X` usually switch an optional **library** on or off (`--with-ssl`, `--without-zlib`). `--enable-X` and `--disable-X` usually switch a **built-in feature** on or off. Projects do not always follow this, so read the `--help` line.

## Why `--prefix` alone is not precise enough

`--prefix` is the flag people reach for first. It is the wrong one when a task demands an *exact* path for the binary. This section shows why, and which flag to use instead.

### How `--prefix` decides the folders

`--prefix` sets the **root** of the whole install tree. `configure` works out every folder below it from that root:

```
  --prefix=/usr/local            (the default)
        ├── bin/     ← $prefix/bin        the binary lands here
        ├── sbin/    ← $prefix/sbin
        ├── lib/     ← $prefix/lib
        └── share/man/ ← $prefix/share/man
```

So `--prefix=/usr` puts the binary at `/usr/bin/<name-the-project-uses-for-its-own-binary>`. That is **not always** `/usr/bin/links`. The project might name its output `links2`, after the tarball, unless it renames it on purpose. `--prefix` only gives you the right result if the project's binary name already matches the one you were asked for.

### Pin the folder with `--bindir`

`--bindir` sets the exact folder for programs, whatever `--prefix` says:

```bash
./configure --bindir=/usr/bin --disable-ipv6
```

Now `make install` copies the binary into `/usr/bin`, whatever folder `--prefix` would have given. The *file name* is still the project's choice, so you check it after the install.

**Rule:** when a task names an exact path for the final binary, use the flag for that exact folder (`--bindir`, `--sbindir`, `--mandir`). Do not trust `--prefix` to work it out.

## Common pitfalls

> [!WARNING]
> - **Guessing a flag name.** Every `configure` is different; an unknown `--enable-foo` may only give a warning that is easy to miss. `./configure --help | grep` first.
> - **Using `--prefix` when the task names an exact binary path.** `$prefix/bin/<name>` is worked out for you, and the `<name>` may not be what you expect. Use `--bindir`.
> - **Confusing `--disable-X` with a path flag.** One removes code, the other moves files. A task that says "without IPv6" wants `--disable-ipv6`, not a folder change.
> - **Assuming `--with-` and `--enable-` are interchangeable.** They usually switch different things (an optional library or a built-in feature). Read the help line.

> *`./configure --help` is the only flag reference. It lists path flags (`--prefix`, `--bindir`, and others) that decide where files go, and feature flags (`--enable`, `--disable`, `--with`, `--without`) that decide what is built in. For an exact binary path, use `--bindir`, not `--prefix`.*
