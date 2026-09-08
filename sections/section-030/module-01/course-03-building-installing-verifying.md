# Part 3 — Building, installing, and verifying

> Prerequisite: [Part 2 — Discovering and choosing configure flags](./course-02-discovering-and-choosing-flags.md). Next: [Section 030 quiz](../quiz.md).

With `configure` run correctly the rest is mechanical — but "the flags were right" is not proof the task is done. This part is the build-and-install step, the staging options worth knowing, and verifying **both** halves of a requirement (path *and* feature) from the built artefact itself.

## Build and install

```bash
# shell: inside the source dir
make
sudo make install
```

`configure` prints a **summary** near the end of its run on many projects — detected features, chosen install paths. Read it before committing to a slow `make`; it is a free sanity check that the flags landed.

Two install options that show up in real work:

- **`sudo make install`** — copies straight into the live system directories `configure` targeted.
- **`make install DESTDIR=/tmp/stage`** — copies into `/tmp/stage/usr/bin/...` instead, a *staging* tree. Used by packagers to build a package without touching the real system. `DESTDIR` is prepended to every path; `--bindir` etc. are relative to it.
- **`make install prefix=/opt/links`** — some Makefiles let you override the prefix at install time without re-running `configure`.

Uninstalling a source build is not guaranteed — `make uninstall` exists only if the project wrote that target. This is why `--prefix=/usr/local` (or `/opt/<name>`) is the safe default: everything is under one removable root.

## Verify both halves, from the artefact

Passing `--bindir=/usr/bin --disable-ipv6` is not evidence. Check each requirement independently after `make install`:

```bash
# 1. exact path — does it resolve from $PATH at the path asked for?
command -v links
# /usr/bin/links

# 2. real compiled binary — not a script, not a dangling symlink
file /usr/bin/links
# /usr/bin/links: ELF 64-bit LSB executable, dynamically linked, ...

# 3. the feature toggle actually took — trust the binary's own report
links -version
# links 2.14
# Features: ...   (ipv6 must NOT appear as enabled)
```

- **`command -v`** (or `which`) confirms the path. Use the exact string the task gave.
- **`file`** confirms it is a genuine ELF binary — a source build gone wrong can leave a wrapper script or a broken symlink.
- **The tool's own `--version` / `-version` / `--help`** is the most direct proof a compiled-in toggle worked. Trust what the built artefact says about itself over what you assume the flags did. Some tools instead expose build info via `ldd` (linked libraries — `ldd /usr/bin/links | grep -i inet6` would show whether an IPv6 library is even linked).

## Closing the filename gap

`--bindir` fixed the **directory**; the **filename** is the `Makefile`'s choice. If the build installed `/usr/bin/links2` but the task wants `/usr/bin/links`:

```bash
ls -l /usr/bin/links /usr/bin/links2 2>&1     # check FIRST
sudo mv /usr/bin/links2 /usr/bin/links        # only if it is not already correct
```

Many source trees already produce the exact name — `mv`-ing a file that is already right is a wasted, risk-bearing step. Always `ls` first.

> [!WARNING]
> - **Treating "I passed the flags" as done.** Verify the path with `command -v`/`file` and the feature with the tool's own version output — independently.
> - **`mv`-ing the binary without checking.** `--bindir` controls the directory, not the filename; the project may already name it correctly. `ls` first.
> - **Assuming `make uninstall` exists.** It only does if the project wrote it. Prefer a self-contained `--prefix` (`/usr/local`, `/opt/<name>`) so removal is `rm -rf` of one tree.
> - **Reading `configure`'s summary as the final proof.** It reports intent; the installed binary reports reality. Check the artefact.

> *After `make && sudo make install`, verify the path with `command -v`/`file` and the feature toggle with the tool's own `--version`/build info — separately — and only `mv` the binary to the required name after `ls` confirms the build did not already use it.*

## Reference

- `man make` — `DESTDIR`, `prefix=` overrides, `install` / `uninstall` targets.
- `man file` — confirming an ELF executable versus a script or data.
- `man ldd` — which shared libraries a binary is linked against, when a feature toggle maps to a library.
