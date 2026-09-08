# Part 1 — The three research questions: search, info, what-provides

> Prerequisite: [module landing page](./course.md). Next: [Part 2 — Installed-only filtering, and the rpm fallback](./course-02-installed-only-and-rpm-fallback.md).

Every zypper research task is one of three questions, in increasing order of specificity — and picking the right one is most of the skill. All three are read-only; none needs `sudo`.

As an analogy (flagged): three questions you would ask a librarian. "Do you have anything about intrusion prevention?" — a **search** (you know the topic, not the title). "Tell me everything about this exact book" — an **info** lookup (you know precisely what you are asking about). "Which book contains this sentence?" — a **what-provides** query (working backward from a fragment to the source). Where it breaks down: a librarian can improvise; zypper matches literally, so `info` needs the exact package name.

## `zypper search` — "I do not know the exact name"

```bash
# shell: inside the zypperbox container
zypper search fail2ban          # shorthand: zypper se
```

```text
S | Name       | Summary                                   | Type
--+------------+-------------------------------------------+--------
  | fail2ban   | Ban IPs after too many failed auth tries  | package
```

`zypper search` scans both package **names** and their **summary text**, case-insensitively — which is why a rough keyword like "intrusion" or "brute-force" surfaces `fail2ban` even though that word is not in the name. The `S` column shows whether each result is already installed (`i`).

## `zypper info` — "tell me everything about this one"

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

`zypper info` matches the **exact literal package name** — no partial matching, no description scanning. Same purpose as `dnf info` / `apt show`: version, arch, vendor, size, source repository, full description, from zypper's cached repository metadata. Changes nothing; run it on a package you have no intention of installing.

## `zypper what-provides` — "what would give me this file?"

```bash
zypper what-provides /usr/sbin/ip      # shorthand: zypper wp
```

```text
S | Name       | Type    | Version   | Arch   | Repository
--+------------+---------+-----------+--------+----------------
  | iproute2   | package | 6.1.0-1.2 | x86_64 | Main Repository
```

zypper's analogue of `dnf provides`. It searches **repository metadata**, not the local filesystem — which is exactly why it answers the question even for a package not installed anywhere on this system. If unsure of the exact path, a `zypper search` on the bare command name first often surfaces a candidate to confirm.

> [!WARNING]
> - **`zypper info <keyword>` to discover a package** → `info` needs the exact name. Use `zypper search`.
> - **Expecting `what-provides` to check the local filesystem** → it reads repo metadata, which is why it works for uninstalled packages.
> - **Running any of these with `sudo`** → all three are read-only; needing root is a sign you reached for the wrong command.

> *`zypper search` matches names + summaries (topic known, name not); `zypper info` needs the exact name and prints full metadata; `zypper what-provides <path>` searches repository metadata to find the package that would supply a file — even an uninstalled one.*

## Reference

- `man zypper` — `search` / `se` (and `-d` for description search, `-t` by type), `info`, `what-provides` / `wp`.
- `man zypper` — `search --provides` and `search --requires` for capability-level queries.
- `zypper info --requires <pkg>` — see a package's dependencies during the `info` lookup.
