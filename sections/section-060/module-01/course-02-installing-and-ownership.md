# Part 2 — Installing directly, and ownership queries in both directions

> Prerequisite: [Part 1 — What `rpm` knows, and inspecting a `.rpm` before you trust it](./course-01-rpm-scope-and-inspecting.md). Next: [Part 3 — Verifying integrity](./course-03-verifying-integrity.md).

`rpm -ivh` installs a standalone `.rpm` and shows exactly where `rpm`'s lack of repository awareness stops it — differently from Debian's `dpkg`. Then the two ownership questions every incident asks, and the flag table that keeps file-path and package-name queries straight.

## `rpm -ivh` refuses on a missing dependency

```bash
# shell: inside rpmbox, root
sudo rpm -ivh /home/candidate/downloads/logship-agent-2.1.0-1.x86_64.rpm
```

`-i` install, `-v` verbose, `-h` the `#####` hash progress bar. If every declared dependency is present, it finishes clean.

If a dependency is **missing**, `rpm` cannot fetch it — no repository — and, unlike `dpkg -i` on Debian which unpacks and leaves things half-configured, `rpm` **refuses the whole transaction** and names the exact missing capability:

```text
error: Failed dependencies:
	libwrap.so.0()(64bit) is needed by logship-agent-2.1.0-1.x86_64
```

So outside a drill focused on raw `rpm`, the practical command for a standalone file is:

```bash
sudo dnf install ./logship-agent-2.1.0-1.x86_64.rpm
```

Given a **local file path** (note the `./`), `dnf` installs that exact file *and* resolves and fetches any missing dependencies from its configured repos — something bare `rpm -i` structurally cannot do.

## Ownership, both directions

### File → package

```bash
rpm -qf /usr/bin/python3
```

```text
python3-3.9.18-1.el9.x86_64
```

`-qf` (`--file`) — **no `-p`** — searches every installed package's file list for that path and prints the owning package's full name-version-release. The direction you reach for when you found a mystery file and need to know whose it is before touching it.

### Package → files

```bash
rpm -ql logship-agent
```

`-ql` — **no `-p`** — the inverse: given an installed package **name**, list every path it placed. Run it *before* removing a package.

### The `-p` table

| Query | Argument | Reads |
|---|---|---|
| `rpm -qip` | a `.rpm` **file** | header metadata, before install |
| `rpm -qlp` | a `.rpm` **file** | file list, before install |
| `rpm -qi` | an installed **package name** | header metadata from the DB |
| `rpm -ql` | an installed **package name** | package → files |
| `rpm -qf` | a **file path** on disk | file → owning package |

The presence or absence of `p` is the single easiest thing to fumble under time pressure. `-qip`/`-qlp` inspect a file; `-qi`/`-ql`/`-qf` hit the database.

> [!WARNING]
> - **Expecting `rpm -ivh` to pull a missing dependency** → it refuses the transaction entirely. Use `dnf install ./file.rpm` for auto-resolution.
> - **`rpm -qf` with a package name / `rpm -ql` with a path** → opposite arguments; `-qf` takes a path, `-ql` takes a name.
> - **Adding `-p` to `-qf` or `-ql`** → those query the installed DB; `-p` makes no sense and errors.
> - **`rpm -ivh` on an already-installed package** → "already installed". Use `-U` (upgrade) if replacing.

> *`rpm -ivh` installs one `.rpm` and refuses outright on a missing dependency (use `dnf install ./file.rpm` to auto-resolve); `-qf` maps a file path → package, `-ql` maps a package name → files, and `-p` only belongs on file-based queries.*

## Reference

- `man rpm` — `-i` / `-U` / `-F` install modes, `-qf`, `-ql`, `--test`.
- `man dnf` — `install <local-file>.rpm` with dependency resolution against configured repos.
- `man rpm` "QUERY OPTIONS" — the full matrix of what `-p` does and does not apply to.
