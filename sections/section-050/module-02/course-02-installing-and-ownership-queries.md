# Installing Directly And Asking Who Owns What

`dpkg -i` installs a standalone `.deb`, and it shows you exactly where `dpkg`'s blindness to repositories stops it. After that come two questions from every real incident: what installed this file, and what did this package install? This part covers the install-and-fix habit and the map of which flag takes a file path and which takes a package name.

## `dpkg -i` and the `--fix-broken` habit

Installing a crate by hand is one command:

```bash
# shell: host, root
sudo dpkg -i /home/candidate/downloads/logtail-utils_2.3.1_amd64.deb
```

If every **dependency** the package declares is already on the ship, this finishes cleanly. A dependency is another crate this one needs in order to work. If one is **missing**, `dpkg -i` cannot fetch it, because it has no repository. So `dpkg` unpacks the package, reports the unmet dependency, leaves the package half-configured, and usually exits with a non-zero code.

The recovery is one habit made of two commands:

```bash
sudo dpkg -i /home/candidate/downloads/logtail-utils_2.3.1_amd64.deb
sudo apt --fix-broken install
```

`apt --fix-broken install` (also written `apt-get -f install`) reads the dependency gap that `dpkg` reported. It fetches the missing packages from APT's configured repositories and finishes configuring `logtail-utils` in the same pass. The split between the two tools in one line: `dpkg` *notices* "needs libfoo, libfoo is missing"; only `apt` can go and *get* libfoo.

`apt install ./logtail-utils_2.3.1_amd64.deb` (note the leading `./`) does both steps at once when you have repository access and just want the package installed. Use `dpkg -i` when the task is specifically about the low-level path.

## Ownership, in both directions

Two questions come up again and again: "which package put this file here?" and "which files did this package put here?". `dpkg` answers both from its database, but each question takes a different kind of argument.

### File to package: "what installed this, and can I touch it?"

```bash
dpkg -S /usr/bin/logtail
```

```text
logtail-utils: /usr/bin/logtail
```

`-S` (`--search`) looks through every installed package's recorded file list for the path. Reach for it in an incident: you found a mystery file and want to know whose it is before you delete or edit it. It takes a **file path**.

### Package to files: "what did this put on my system?"

```bash
dpkg -L logtail-utils
```

`-L` (`--listfiles`) is the reverse. Given a package **name**, it lists every path its `.deb` placed. Run it *before* removing a package, so what disappears is never a surprise.

### The flag map: the easiest place to lose time

Most `dpkg` mistakes come from giving a flag the wrong kind of argument. This map groups the flags by what they take:

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
| `-s` / `--status` | a package **name** | installed metadata and the `Status:` line |
| `-L` / `--listfiles` | a package **name** | package to files |
| `-S` / `--search` | a **file path** | file to package |

Two quick checks show whether an install really finished:

```bash
dpkg -s logtail-utils          # Status: should read "install ok installed"
dpkg -l | grep logtail-utils   # compact status-code column
```

`dpkg -s` prints a `Status:` line, and `dpkg -l` prints a short two-letter status code in its first column. A cleanly installed package shows `ii` there.

## Common pitfalls

> [!WARNING]
> - **Stopping after a non-zero `dpkg -i`.** The package is half-installed. `sudo apt --fix-broken install` is the second half of the same job.
> - **Giving `dpkg -S` a package name, or `dpkg -L` a path.** They are opposites: `-S` takes a path, `-L` takes a name. Swapped, you get "no path found" or "package not installed".
> - **Deleting a file because it "looks unowned".** Run `dpkg -S <path>` first; a package may own it and expect it to be there.
> - **Running `dpkg -L` on a package that is not installed.** It errors. Check with `dpkg -s` first.
