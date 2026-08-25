# Chapter 2: dpkg Low-Level Package Management

Every time `apt install` finishes and prints its cheerful summary, something quieter is happening underneath: `apt` hands the actual work of unpacking files and registering them in a local database to a much older, much more literal-minded tool called `dpkg`. `apt` is the layer that resolves dependencies and fetches packages over the network; `dpkg` is the layer that actually does the installing, one `.deb` file at a time, with no awareness of the internet, no awareness of repositories, and no ability to go fetch anything it doesn't already have in hand.

Most days, you never need to think about `dpkg` directly. But every so often someone hands you a standalone `.deb` — a vendor's one-off build, an internal tool, something downloaded once and never published to any repository APT can see — and `apt install ./package.deb` isn't quite what's being asked for, or isn't available. This chapter is about operating at that lower level directly: inspecting a `.deb` before you trust it, installing it, asking ownership questions in both directions, and recovering when something is left in a state that isn't quite installed and isn't quite absent either.

---

## Part I: One Thing at a Time

Keep this sentence in your head for the rest of the chapter: **`dpkg` knows about exactly one thing at a time** — the `.deb` file (or already-installed package) directly in front of it. No repositories. No dependency fetching. No automatic anything. Every flag you're about to learn either operates on a literal file path sitting on disk, or on the name of something already recorded as installed. Confusing the two is the single most common mistake with `dpkg`, so we'll call it out explicitly as we go.

---

## Part II: Looking Before You Leap — Inspecting a `.deb` File

Suppose a colleague hands you `/home/candidate/downloads/logtail-utils_2.3.1_amd64.deb`. Before installing anything, you want to know what it actually is.

```bash
dpkg -I /home/candidate/downloads/logtail-utils_2.3.1_amd64.deb
```

`-I` (info) reads the `control` file embedded inside the `.deb` archive — every `.deb` is really just an archive containing the files it will install *plus* a small metadata block describing itself — and prints the package name, version, architecture, maintainer, an installed-size estimate, and any declared `Depends:`/`Recommends:` lines. Crucially, this touches nothing about your system's installed-package database. You're reading a file, not changing any state.

Next, ask what it would actually put on disk:

```bash
dpkg -c /home/candidate/downloads/logtail-utils_2.3.1_amd64.deb
```

`-c` (contents) lists every path the archive would place on disk, complete with the permissions and ownership that will be applied. This is your chance to catch something unexpected — a `.deb` that claims to be a small logging utility but wants to drop files into `/etc/cron.d/` or overwrite something already in `/usr/bin` is a five-second red flag you'd otherwise only discover after the fact.

Notice the pattern here: both `-I` and `-c` take a literal path to a `.deb` file sitting on disk. They work identically whether or not the package ends up installed. Hold that thought — it's about to matter.

---

## Part III: Installing Directly

Once you're satisfied with what you've seen, install it:

```bash
sudo dpkg -i /home/candidate/downloads/logtail-utils_2.3.1_amd64.deb
```

If every dependency `logtail-utils` declares is already satisfied on this system, this finishes cleanly and you're done. But here's the limitation that defines this entire chapter: if a declared dependency is *not* already installed, `dpkg -i` does not go fetch it — it can't, because `dpkg` has no concept of a repository to fetch anything *from*. It proceeds with the install, then reports the unmet dependency and leaves the package in a partially-configured state, often exiting non-zero.

The standard, expected recovery is a two-step pattern you should treat as a single reflex rather than two separate decisions:

```bash
sudo dpkg -i /home/candidate/downloads/logtail-utils_2.3.1_amd64.deb
sudo apt --fix-broken install
```

`apt --fix-broken install` picks up exactly where `dpkg` left off: it reads the dependency gap `dpkg` just reported, reaches out to APT's configured repositories to fetch whatever's actually missing, and finishes configuring the package in the same pass. This is the layer division in miniature — `dpkg` can *detect* "this needs libfoo, and libfoo isn't here," but only `apt`, with its repository awareness, can actually go get libfoo.

---

## Part IV: Ownership, In Both Directions

Once something is installed, two questions come up constantly, and they point in opposite directions.

**"What installed this file, and can I safely touch it?"** — the reverse lookup, file to package:

```bash
dpkg -S /usr/bin/logtail
```

```text
logtail-utils: /usr/bin/logtail
```

`-S` (search) scans every installed package's recorded file list for a match. This is usually the direction people reach for first in a real incident: you've found a mystery file and want to know whose responsibility it is before you delete or modify it.

**"What did this package actually put on my system?"** — the forward lookup, package to files:

```bash
dpkg -L logtail-utils
```

`-L` (listfiles) is the exact inverse: given a package name, it lists every path that package's `.deb` placed on the filesystem at install time. This is the step worth running *before* removing a package, so "what's about to disappear" is never a surprise.

Notice something important: both `-S` and `-L` in this section take a package **name**, not a file path — the opposite of `-I` and `-c` from Part II, which took a file path. This distinction — file-path flags versus package-name flags — is the single easiest place to lose time under exam pressure, so it's worth drilling until it's automatic.

| Flag | Operates on | Direction |
|---|---|---|
| `-I` / `--info` | a `.deb` **file** path | metadata, before install |
| `-c` / `--contents` | a `.deb` **file** path | file list, before install |
| `-s` / `--status` | an installed **package name** | metadata, after install |
| `-L` / `--listfiles` | an installed **package name** | package → files |
| `-S` / `--search` | a file **path** on disk | file → package |

Round it out with a general status check:

```bash
dpkg -s logtail-utils
dpkg -l | grep logtail-utils
```

`dpkg -s` (status) is the installed-package equivalent of the `-I` metadata block, but now reflecting the actual installed record — including a `Status:` line that should read `install ok installed` for anything cleanly finished. `dpkg -l` lists every known package with a compact status-code column; grepping it is the fastest possible sanity check.

---

## Part V: Reading the Status Codes

That compact column in `dpkg -l` output is worth decoding properly, because a package that isn't quite installed and isn't quite absent shows up here, not as an error message, but as a two-letter code easy to misread if you've never looked closely.

```text
Desired=Unknown/Install/Remove/Purge/Hold
| Status=Not/Inst/Conf-files/Unpacked/halF-conf/Half-inst/trig-aWait/Trig-pend
|/ Err?=(none)/Reinst-required (Status,Err: uppercase=bad)
||/ Name           Version      Architecture Description
+++-==============-============-============-=================
ii  logtail-utils  2.3.1        amd64        internal log utility
iF  cowsay         3.03+dfsg2-8 all          configure a cow
```

The first letter is the *desired* action (almost always `i` for install), the second is the *current* status. `ii` — clean, fully configured, exactly what you want to see. `iU` means "Unpacked but not yet configured." `iF` means "half-configured" — files are on disk, but the package's post-install configuration step never finished. Both are the fingerprint of an interruption: a killed process, a lost SSH session mid-install, a power event. Nothing about them means "broken beyond repair" — they mean "left mid-step."

---

## Part VI: Recovering an Interrupted Package

Suppose you spot exactly that — a package sitting at `iF` or `iU` instead of the clean `ii` you expect. The recovery is a specific, well-known two-command sequence:

```bash
sudo dpkg --configure -a
```

The `-a`/`--pending` modifier is the important part: this tells `dpkg` to finish configuring **every** package currently sitting in a pending or incomplete state — not just one you name — which is exactly the right approach when you don't know the full scope of what an interruption affected. For most interruptions, where the files are already correctly on disk and only the configuration step was cut short, this alone resolves the problem completely.

Run the safety net immediately after, even if the above reported success:

```bash
sudo apt --fix-broken install
```

This catches the other failure mode — a genuinely missing dependency, rather than just an interrupted process — which `dpkg --configure -a` alone cannot fix, for the same reason `dpkg -i` couldn't fix it in Part III: no repository awareness. Pairing these two commands, in this order, is the standard, expected pattern for "this system's package state looks inconsistent," not a rare edge case reserved for disasters.

---

## Self-Check and Verification

Test your understanding before moving to the hands-on lab:
1.  **File vs. Name**: You need to know every file a package called `acme-agent` placed on disk. Which flag, and does it take a file path or a package name? *(Answer: `dpkg -L acme-agent` — it takes the package name.)*
2.  **The Missing Piece**: `dpkg -i` correctly detects that a `.deb` needs a library that isn't installed. Why can't `dpkg` just go install that library itself? *(Answer: `dpkg` has no concept of a repository or a network — it only knows about the `.deb` file(s) it's explicitly handed and the local package database; fetching anything requires `apt`.)*
3.  **Reading the Column**: `dpkg -l` shows a package as `iU`. Is this package installed, not installed, or something in between — and what's the first command you'd run? *(Answer: something in between — "Unpacked" but not yet configured; run `sudo dpkg --configure -a`, then `sudo apt --fix-broken install` as a safety net.)*
