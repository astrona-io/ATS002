# Part 2 — Installing directly, and ownership queries in both directions

> Prerequisite: [Part 1 — What `dpkg` knows, and inspecting a `.deb` before you trust it](./course-01-dpkg-scope-and-inspecting-a-deb.md). Next: [Part 3 — Status codes and recovering an interrupted package](./course-03-status-codes-and-recovery.md).

`dpkg -i` installs a standalone `.deb` — and shows you exactly where `dpkg`'s lack of repository awareness stops it. Then two questions that come up in every real incident: what installed this file, and what did this package install. This part is the install-plus-fixup reflex and the file-path-vs-package-name flag map.

## `dpkg -i` and the `--fix-broken` reflex

```bash
# shell: host, root
sudo dpkg -i /home/candidate/downloads/logtail-utils_2.3.1_amd64.deb
```

If every declared dependency is already present, this finishes clean. If a dependency is **missing**, `dpkg -i` does not fetch it — it cannot, no repository — so it unpacks the package, reports the unmet dependency, leaves it half-configured, and usually exits non-zero.

The recovery is one reflex, two commands:

```bash
sudo dpkg -i /home/candidate/downloads/logtail-utils_2.3.1_amd64.deb
sudo apt --fix-broken install
```

`apt --fix-broken install` (also `apt-get -f install`) reads the dependency gap `dpkg` reported, fetches the missing packages from APT's configured repositories, and finishes configuring `logtail-utils` in the same pass. The layer division in one line: `dpkg` *detects* "needs libfoo, libfoo absent"; only `apt` can go *get* libfoo.

(`apt install ./logtail-utils_2.3.1_amd64.deb` — note the leading `./` — does both steps at once when you have repo access and just want it installed. `dpkg -i` is the tool when the task is specifically about the low-level path.)

## Ownership, both directions

### File → package: "what installed this, can I touch it?"

```bash
dpkg -S /usr/bin/logtail
```

```text
logtail-utils: /usr/bin/logtail
```

`-S` (`--search`) scans every installed package's recorded file list for the path. The direction you reach for in an incident: you found a mystery file and want to know whose it is before you delete or edit it. Takes a **file path**.

### Package → files: "what did this put on my system?"

```bash
dpkg -L logtail-utils
```

`-L` (`--listfiles`) is the inverse: given a package **name**, list every path its `.deb` placed. Run it *before* removing a package so "what disappears" is never a surprise.

### The flag map — the easiest place to lose time

```
  operates on a .deb FILE PATH          operates on an installed PACKAGE NAME
  ────────────────────────────          ────────────────────────────────────
  dpkg -I   control metadata            dpkg -s   installed status + metadata
  dpkg -c   contents / file list        dpkg -L   files this package installed
                                        dpkg -l   one-line status of all packages

  operates on a FILE PATH already on disk
  ──────────────────────────────────────
  dpkg -S   which package owns that path
```

| Flag | Argument | Answers |
|---|---|---|
| `-I` / `--info` | a `.deb` **file** | metadata, before install |
| `-c` / `--contents` | a `.deb` **file** | file list, before install |
| `-s` / `--status` | a package **name** | installed metadata + `Status:` line |
| `-L` / `--listfiles` | a package **name** | package → files |
| `-S` / `--search` | a **file path** | file → package |

General checks:

```bash
dpkg -s logtail-utils          # Status: should read "install ok installed"
dpkg -l | grep logtail-utils   # compact status-code column (Part 3)
```

> [!WARNING]
> - **Stopping after a non-zero `dpkg -i`** → the package is half-installed. `sudo apt --fix-broken install` is the second half of the same operation.
> - **`dpkg -S` with a package name, or `dpkg -L` with a path** → they are opposite: `-S` takes a path, `-L` takes a name. Swapped, you get "no path found" / "package not installed".
> - **Deleting a file because it "looks unowned"** → run `dpkg -S <path>` first; a package may own it and expect it.
> - **`dpkg -L` on a not-installed package** → errors. Confirm with `dpkg -s` first.

> *`dpkg -i` installs one `.deb` and, on a missing dependency, leaves it half-configured until `apt --fix-broken install` fetches the gap; `-S` maps a file path → owning package, `-L` maps a package name → its files, and the file-path vs package-name split is the flag map to memorise.*

## Reference

- `man dpkg` — `-i`, `-S`, `-L`, `-s`, `-l`, and the `--fix-broken` note pointing at `apt-get -f install`.
- `man apt-get` — `-f` / `--fix-broken install`: what it does with a partially-configured package.
- `man dpkg-query` — the query backend behind `-s` / `-L` / `-S` / `-l`, with `-W --showformat` for scripting.
