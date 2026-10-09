# Search, Info and What-Provides

Every `zypper` research task is one of three questions, each more exact than the one before. Picking the right question is most of the skill. All three commands only read, so none needs `sudo`.

Picture the depot's catalogue on your ship. You can browse it by topic when you do not know a crate's name (**search**). You can open one crate's full label when you know its exact name (**info**). Or you can ask which crate holds one particular part (**what-provides**). Unlike a helpful clerk, `zypper` matches names literally, so `info` needs the exact package name.

Run every command inside the `zypperbox` container (`docker exec -it zypperbox bash`).

## `zypper search`: "I do not know the exact name"

Look for a package by a word you know:

```bash
# shell: inside the zypperbox container
zypper search fail2ban          # shorthand: zypper se
```

```text
S | Name       | Summary                                   | Type
--+------------+-------------------------------------------+--------
  | fail2ban   | Ban IPs after too many failed auth tries  | package
```

`zypper search` looks through package **names**, and it ignores upper and lower case. The `S` (status) column shows whether a result is already installed (`i`); here it is empty, so `fail2ban` is not installed.

To also look through the one-line summary and the longer description, add `-d` (`zypper se -d intrusion`). That is how a rough keyword such as "intrusion" or "brute" can find `fail2ban` even when the word is not in its name. Add `-t` to limit results to one type, for example `-t package` or `-t patch`.

## `zypper info`: "tell me everything about this one"

When you know the exact name, read the full label:

```bash
zypper info nginx
```

```text
Repository     : Main Repository
Name           : nginx
Version        : 1.25.3-1.1
Arch           : x86_64
Vendor         : openSUSE
Installed      : No
Summary        : A HTTP and reverse proxy server
```

`zypper info` matches the **exact package name** only. It does no partial matching and does not search descriptions. It does the same job as `dnf info` or `apt show`: it prints the version, architecture, vendor, size, source repository and full description, all from the cached repository metadata. The sample above is shortened; the real output has more fields.

It changes nothing, so you can run it on a package you never plan to install. Add `--requires` (`zypper info --requires nginx`) to also see what the package depends on.

## `zypper what-provides`: "what would give me this file?"

When you know a file or command but not the package, ask which package supplies it:

```bash
zypper what-provides /usr/sbin/ip      # shorthand: zypper wp
```

```text
S | Name       | Type    | Version   | Arch   | Repository
--+------------+---------+-----------+--------+----------------
  | iproute2   | package | 6.1.0-1.2 | x86_64 | Main Repository
```

This is the `zypper` version of `dnf provides`. It searches the **repository metadata**, not the files on your disk. That is exactly why it can answer even for a package that is not installed anywhere on this system.

If you are not sure of the exact path, run `zypper search` on the bare command name first; it often turns up a candidate you can then confirm. For deeper questions, `zypper search --provides <capability>` and `zypper search --requires <capability>` search what packages offer and what they need.

In short: `zypper search` matches names (and with `-d`, descriptions) when you know the topic but not the name; `zypper info` needs the exact name and prints the full details; `zypper what-provides <path>` searches repository metadata to find the package that would supply a file, even one that is not installed.

## Common pitfalls

> [!WARNING]
> - **Using `zypper info <keyword>` to discover a package.** `info` needs the exact name. Use `zypper search`.
> - **Expecting `what-provides` to look at the local disk.** It reads repository metadata, which is why it works for packages that are not installed.
> - **Running any of these with `sudo`.** All three only read. If you think you need root, you picked the wrong command.
