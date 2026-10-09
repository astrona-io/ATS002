# Installing Directly and Ownership Queries

Astronaut, you have read the label on the crate. Now you load it, and then you answer the two questions every incident asks: "which crate did this file come from?" and "which files came out of this crate?" This part shows where `rpm`'s lack of repository knowledge stops it, and the small table that keeps file and package queries apart.

## Installing a single .rpm file

`rpm` can install a `.rpm` file straight from disk. What it cannot do is fetch anything that file needs. That one limit decides which install command you pick.

### rpm -ivh

Install the file you inspected:

```bash
# shell: inside rpmbox, root
sudo rpm -ivh /home/candidate/downloads/logship-agent-2.1.0-1.x86_64.rpm
```

`-i` means install, `-v` means verbose, and `-h` prints a progress bar of `#` marks. If every declared dependency is already present, the install finishes cleanly.

Inside `rpmbox` you are already the root user, so `sudo` is not needed there. The commands keep `sudo` because on a real server you log in as a normal user. If the container answers `sudo: command not found`, run the same command without `sudo`.

### When a dependency is missing

If a dependency is **missing**, `rpm` cannot fetch it, because it knows no repository. It also does not install half the package. It **refuses the whole transaction** and names the exact missing capability:

```text
error: Failed dependencies:
	libwrap.so.0()(64bit) is needed by logship-agent-2.1.0-1.x86_64
```

This output is an example of what the refusal looks like. The `logship-agent` package in the mission only needs `bash` and `coreutils`, which are already there, so its install succeeds.

Debian's `dpkg -i` behaves differently: it unpacks the package and leaves it half-configured. `rpm` leaves the system exactly as it was.

### dnf install with a local file

Outside a drill that is about raw `rpm`, the practical command for a single file is:

```bash
sudo dnf install ./logship-agent-2.1.0-1.x86_64.rpm
```

Given a **local file path** (note the `./`), `dnf` installs that exact file. It also works out any missing dependencies and fetches them from its configured repositories, something bare `rpm -i` cannot do. If you are replacing a package that is already installed, `rpm -ivh` stops with "already installed"; `rpm -U` (upgrade) is the option for that.

## Ownership in both directions

Once packages are on board, two questions come up again and again. Both go to the RPM database, so neither one takes `-p`.

### File to package

You found a file and want to know whose it is before you touch it:

```bash
rpm -qf /usr/bin/python3
```

```text
python3-3.9.18-1.el9.x86_64
```

`-qf` (long form `--file`) searches every installed package's file list for that path. It prints the owner's full name, version and release.

### Package to files

The other way round, from a package name to its files:

```bash
rpm -ql logship-agent
```

`-ql` takes an installed package **name** and lists every path it placed. Run it before you remove a package, so you know what will go.

## The -p table

Whether `p` is in the flags or not is the easiest thing to get wrong under time pressure. This table keeps the five queries apart:

| Query | Argument | Reads |
|---|---|---|
| `rpm -qip` | a `.rpm` **file** | header metadata, before install |
| `rpm -qlp` | a `.rpm` **file** | file list, before install |
| `rpm -qi` | an installed **package name** | header metadata from the database |
| `rpm -ql` | an installed **package name** | package → files |
| `rpm -qf` | a **file path** on disk | file → owning package |

`-qip` and `-qlp` inspect a file. `-qi`, `-ql` and `-qf` ask the database.

## Common pitfalls

> [!WARNING]
> - **Expecting `rpm -ivh` to fetch a missing dependency.** It refuses the whole transaction. Use `dnf install ./file.rpm` when you want dependencies resolved for you.
> - **Giving `rpm -qf` a package name, or `rpm -ql` a path.** They take opposite arguments: `-qf` takes a path, `-ql` takes a name.
> - **Adding `-p` to `-qf` or `-ql`.** Those ask the installed database, so `-p` makes no sense there and gives an error.
> - **Running `rpm -ivh` on a package that is already installed.** It stops with "already installed". Use `-U` (upgrade) to replace it.
