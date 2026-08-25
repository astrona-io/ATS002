# Chapter 1: RPM Low-Level Package Management

Every time `dnf install` finishes and prints its cheerful transaction summary, something quieter is happening underneath: `dnf` hands the actual work of unpacking files and writing them into a local database to a much older, much more literal-minded tool called `rpm`. `dnf` is the layer that resolves dependencies and fetches packages over the network from configured repositories; `rpm` is the layer that actually does the installing, one `.rpm` file at a time, with no awareness of the internet, no awareness of repositories, and no ability to go fetch anything it doesn't already have in hand.

Most days, you never need to think about `rpm` directly. But every so often someone hands you a standalone `.rpm` — a vendor's one-off build, an internal tool, something downloaded once and never published to any repository `dnf` can see — and `dnf install ./package.rpm` isn't quite what's being asked for, or isn't available. This chapter is about operating at that lower level directly: inspecting a `.rpm` before you trust it, installing it, asking ownership questions in both directions, and verifying that an installed package's files haven't drifted from what was originally recorded.

---

## Working In This Lab: The `rpmbox` Container

Before we go any further, a word about *where* you'll actually be typing these commands. This repository's practice VMs only come in one flavor: an Ubuntu 24.04 image. There is no Rocky Linux or RHEL virtual machine available in this platform. RPM and `dnf` are not Ubuntu tools — Ubuntu uses `dpkg`/`apt` instead — so to give you a genuinely real `rpm` experience rather than a faked one, this lab's bootstrap does something deliberate: it installs Docker on the Ubuntu VM, then starts a long-lived, privileged Rocky Linux 9 container named `rpmbox` and leaves it running for your whole session.

Everything inside that container is the real thing — a real Rocky Linux 9 userspace, a real `rpm` binary, a real RPM database. Nothing is simulated. The only unusual part is that you reach it through Docker instead of SSH-ing directly into a Rocky VM. To get a shell inside it:

```bash
docker exec -it rpmbox bash
```

Run every `rpm` command in this chapter from that shell. If you'd rather stay on the Ubuntu host and run one-off commands without opening an interactive shell, you can prefix any command with `docker exec rpmbox` instead, for example `docker exec rpmbox rpm -qa`. Either approach reaches the same real Rocky Linux 9 environment — pick whichever fits how you like to work.

---

## Part I: One Thing at a Time

Keep this sentence in your head for the rest of the chapter: **`rpm` knows about exactly one thing at a time** — the `.rpm` file (or already-installed package) directly in front of it. No repositories. No dependency fetching. No automatic anything. Every flag you're about to learn either operates on a literal file path sitting on disk, or on the name of something already recorded as installed in the local database under `/var/lib/rpm`. Confusing the two is the single most common mistake with `rpm`, so we'll call it out explicitly as we go.

---

## Part II: Looking Before You Leap — Inspecting a `.rpm` File

Suppose a colleague hands you `/home/candidate/downloads/logship-agent-2.1.0-1.x86_64.rpm`, an internal monitoring agent. Before installing anything, you want to know what it actually is:

```bash
rpm -qip /home/candidate/downloads/logship-agent-2.1.0-1.x86_64.rpm
```

`-q` (query) combined with `-i` (info) and `-p` (treat the next argument as a literal file path) reads the package header embedded in the archive itself — every `.rpm` is really just a cpio archive plus a metadata header describing itself — and prints the name, version, release, architecture, vendor, install size, build date, and description. This touches nothing about your installed-package database. You're reading a file, not changing any state.

The `-p` here is the single most important flag in this whole chapter. Drop it, and `rpm -qi logship-agent-2.1.0-1.x86_64.rpm` goes looking for an *installed* package literally named after that file path — which obviously doesn't exist — and reports "package is not installed," a confusing error for a problem that's really just a missing flag.

Next, ask what the archive would actually put on disk:

```bash
rpm -qlp /home/candidate/downloads/logship-agent-2.1.0-1.x86_64.rpm
```

`-l` (list) paired with the same `-p` prints every path the archive would place on disk if installed — your chance to catch something unexpected before you commit to anything. And while we're still just reading the file, check what it declares it needs:

```bash
rpm -qp --requires /home/candidate/downloads/logship-agent-2.1.0-1.x86_64.rpm
```

This tells you, in advance, whether a plain `rpm -ivh` is likely to succeed cleanly or refuse over an unmet dependency — useful triage before you ever run the install.

---

## Part III: Installing Directly

Once you're satisfied with what you've seen, install it:

```bash
sudo rpm -ivh /home/candidate/downloads/logship-agent-2.1.0-1.x86_64.rpm
```

`-i` performs the install, `-v` gives verbose output as it processes, and `-h` prints the familiar `#####` hash-mark progress bar. Here's the limitation that defines this entire chapter: if every dependency `logship-agent` declares (say, `bash` and `coreutils`) is already satisfied on the system, this finishes cleanly. But if a declared dependency is *not* already installed, `rpm` doesn't go fetch it — it can't, because `rpm` has no concept of a repository to fetch anything *from*. Unlike `dpkg -i` on a Debian system, it also does not proceed and leave things half-configured; it refuses the transaction outright and names the exact missing capability.

This is precisely why, outside a drill focused on raw `rpm`, the practically preferred command for a standalone file is `sudo dnf install ./logship-agent-2.1.0-1.x86_64.rpm` — `dnf`, given a local file path instead of a repository package name, still resolves and fetches any missing dependencies from its configured repos while installing that exact local file, something bare `rpm -i` structurally cannot do.

---

## Part IV: Ownership, In Both Directions

Once something is installed, two questions come up constantly, and they point in opposite directions.

**"What installed this file, and can I safely touch it?"** — the reverse lookup, file to package:

```bash
rpm -qf /usr/bin/python3
```

`-f`/`--file` searches every installed package's recorded file list for a match and prints the owning package's full name-version-release string. Notice: no `-p` here. `/usr/bin/python3` is a file already on disk, owned by something already installed — the question is about the database, not about an archive.

**"What did this package actually put on my system?"** — the forward lookup, package to files:

```bash
rpm -ql logship-agent
```

`-l` without `-p` is the exact inverse of Part II's file-based listing: given an installed package's *name*, it lists every path that package placed on the filesystem at install time. Run this before ever removing a package, so "what's about to disappear" is never a surprise.

| Flag | Operates on | Direction |
|---|---|---|
| `-qip` | a `.rpm` **file** path | metadata, before install |
| `-qlp` | a `.rpm` **file** path | file list, before install |
| `-qi` | an installed **package name** | metadata, after install |
| `-ql` | an installed **package name** | package → files |
| `-qf` | a file **path** on disk | file → package |

That `p` modifier is the single easiest place to lose time under exam pressure — drill it until switching between file-based and name-based queries is automatic.

---

## Part V: Verifying Integrity

Installing a package is not the end of the story — files can drift after the fact, whether from a legitimate configuration edit or something worth worrying about. `rpm -V` answers "has anything changed since install?":

```bash
rpm -V logship-agent
```

Clean output is *no output at all*. `rpm -V` only prints a line for a file that fails one or more checks, using a compact code for each attribute it compares against what was recorded at install time:

```text
S.5....T.  c /etc/logship-agent/agent.conf
```

Here, `S` (size), `5` (checksum), and `T` (mtime) have all changed. On a file flagged `c` (a config file), that's expected and harmless — someone legitimately edited it. The exact same output pattern on a binary under `/usr/bin` instead, with no `c` flag, would be a serious integrity red flag worth investigating immediately. A bare `.` in any column means "unchanged, matches what was recorded."

Finally, round out your dependency picture from the installed side:

```bash
rpm -q --requires logship-agent
rpm -q --provides logship-agent
```

`--requires` lists everything the package needs to function; `--provides` lists what capabilities the package itself offers to satisfy *other* packages' `Requires:` lines. These are not symmetric — a packager cares about `--provides` because a package's declared capabilities don't have to match its literal name, and other packages' dependency resolution keys off exactly this list.

---

## Self-Check and Verification

Test your understanding before moving to the hands-on lab:
1. **File vs. Name**: You need to know every file a package called `acme-agent` placed on disk. Which flag, and does it take a file path or a package name? *(Answer: `rpm -ql acme-agent` — it takes the package name, no `-p`.)*
2. **The Missing Piece**: `rpm -ivh` correctly detects that a `.rpm` needs a library that isn't installed. Why can't `rpm` just go install that library itself? *(Answer: `rpm` has no concept of a repository or a network — it only knows about the `.rpm` file(s) it's explicitly handed and the local database; fetching anything requires `dnf`.)*
3. **Reading a Verify Line**: `rpm -V` prints `S.5....T.  c /etc/app/app.conf`. Is this alarming? *(Answer: No — the `c` flag marks it as a config file, and size/checksum/mtime drift on a config file is the expected fingerprint of a legitimate manual edit. The same pattern on an unflagged binary would be alarming.)*
