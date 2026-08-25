# Zypper Package Information Lookup

Installing something without knowing what it actually is, or which package would even provide the file you're missing, is how production systems accumulate surprises nobody signed off on. You have already built this instinct with `apt` and `dnf` earlier in this domain — this module gives you the exact same discipline, expressed through zypper's own command surface, on a genuine openSUSE system.

Think of zypper's research commands as three different questions you'd ask a librarian, in increasing order of specificity. "Do you have anything about intrusion prevention?" is a **search** — you don't know the exact title, just the topic. "Tell me everything about this exact book — author, edition, page count" is an **info** lookup — you already know precisely what you're asking about. "Which book on your shelves would contain this specific sentence?" is a **what-provides** query — you're working backward from a fragment to the source. Every zypper research task in this module is one of those three questions, and picking the right one is most of the skill.

---

## Working Inside the zypperbox Container — Same as Module 1

As in the previous module, none of this happens on the Ubuntu host directly. All of the commands below run inside the long-lived `zypperbox` container, which bootstrap already started from the real `opensuse/leap:15.6` image:

```bash
docker exec -it zypperbox bash
```

Everything you look up in this module is genuine openSUSE repository metadata — real package names, real versions, real dependency graphs — reached through a real `zypper` binary. There is nothing simulated about the answers you'll get; only the disk they live on is virtualized.

One detail worth internalizing up front: every command in this module is **read-only**. None of them install, remove, or change anything about the system. That means, refreshingly, you never need `sudo` for any of them — a lookup command asking to be run as root is usually a sign you've reached for the wrong tool.

---

## Question One: "I Don't Know the Exact Name" — `zypper search`

When a task describes *functionality* rather than naming an exact package, you start with a keyword search:

```bash
zypper search fail2ban
```

```text
S | Name          | Summary                                  | Type
--+---------------+-------------------------------------------+--------
  | fail2ban      | Ban IPs after too many failed auth tries   | package
```

`zypper search` (shorthand: `zypper se`) scans both package **names** and their **summary/description text**, case-insensitively. That second part matters — it's why searching a rough keyword like "intrusion" or "brute-force" can surface a package like `fail2ban` even if that exact word never appears in the package's own name. The `S` column in the output tells you at a glance whether each result is already installed.

---

## Question Two: "Tell Me Everything About This One Package" — `zypper info`

Once you know the exact name, pull its full metadata without touching the installed system at all:

```bash
zypper info nginx
```

```text
Information for package nginx:
-------------------------------
Repository     : Main Repository
Name           : nginx
Version        : 1.25.3-1.1
Arch           : x86_64
Vendor         : openSUSE
Installed Size : 2.3 MiB
Installed      : No
Status         : not installed
Summary        : A HTTP and reverse proxy server
Description    :
    nginx is an HTTP and reverse proxy server...
```

`zypper info` only matches the **exact, literal package name** — no partial matching, no description scanning the way `search` does. This mirrors `dnf info` / `apt show` in purpose exactly: version, architecture, vendor, size, repository source, and full description, purely from zypper's cached repository metadata. Running it changes nothing — you can `zypper info` a package you have zero intention of installing, purely to check what it would pull in first.

---

## Question Three: "What Would Give Me This File?" — `zypper what-provides`

Sometimes you're working backward: a script fails because a command isn't found, and you need to know which package would supply it — before you install anything.

```bash
zypper what-provides /usr/sbin/ip
```

```text
S | Name       | Type    | Version   | Arch   | Repository
--+------------+---------+-----------+--------+----------------
  | iproute2   | package | 6.1.0-1.2 | x86_64 | Main Repository
```

This is zypper's direct analog of `dnf provides` — same underlying question, same kind of repository-published metadata, just zypper's own subcommand name. Critically, `what-provides` searches **repository metadata**, not the local filesystem — which is exactly why it can answer the question even for a package that isn't installed anywhere on this system yet. If you're not confident of the exact file path, a `zypper search` on the bare command name first often surfaces a strong candidate package to confirm with `what-provides` or `info`.

---

## Filtering to What's Already There — `search --installed-only`

The last research pattern is the inverse of the first three: not "what's available," but "what's already installed, matching this pattern."

```bash
zypper search --installed-only 'python3-*'
# shorthand: zypper se -i 'python3-*'
```

```text
S | Name              | Summary                        | Type
--+-------------------+---------------------------------+--------
i | python3-base      | Python 3 interpreter            | package
i | python3-pip       | Python package installer        | package
```

The `-i` / `--installed-only` flag restricts results to packages that are both a pattern match **and** currently present on the system, in a single zypper-native command. It's tempting to reach for an unfiltered `zypper search 'python3-*' | grep` instead, mimicking the raw-`grep` habit from earlier modules — but zypper already gives you the filter natively, and using it directly is both faster and less error-prone than eyeballing a status column across dozens of results.

---

## The RPM Fallback: Zero Network, Zero Zypper

Because openSUSE is RPM-based underneath zypper, the standalone `rpm -qi` / `rpm -qf` commands you've already used elsewhere in this domain work here completely unchanged:

```bash
rpm -q nginx 2>/dev/null && rpm -qi nginx || echo "nginx not currently installed"
```

The trade-off between these two toolsets is structural, not stylistic. `rpm -qi`/`rpm -qf` read directly from the local RPM database — zero network dependency, and they reflect exactly what's installed right now, this second. But that's also their ceiling: they can only ever see what's already on the system. They cannot tell you what a package *not yet installed* would provide, the way `zypper what-provides` or `zypper info` can, because that information only exists in repository metadata the RPM tools never touch.

---

## Self-Check and Verification

To prove your zypper research fluency before moving on:

1. Inside `zypperbox`, use `zypper search` with a functional keyword (not an exact package name) and confirm it surfaces a relevant package via its description text.
2. Run `zypper info` against a package you have not installed and confirm the metadata prints without changing anything on the system.
3. Pick a common command whose owning package you don't already know (`traceroute`, `dig`, `ss`) and use `zypper what-provides` to identify it.
4. Run `zypper search --installed-only` with a broad pattern and compare the count against a manual `rpm -qa | grep` sanity check.
5. Confirm none of the above required `sudo` — if you found yourself elevating privileges for a lookup, you reached for the wrong command.
