# Chapter 4: APT Package Information Lookup

"It installed without an error" and "it's the version and source I expected" are two different claims, and conflating them is how production systems accumulate quiet surprises — the wrong build, an unexpectedly old version, a package pulled from a repository nobody meant to trust. Before you install, remove, or upgrade anything, there is a whole layer of APT tooling whose only job is to answer questions, entirely read-only: what exists, what it contains, where it would come from, and what's already on the system.

This chapter is about that research layer — the tools you reach for *before* committing to a change, not after.

---

## Part I: Finding a Package When You Only Have a Rough Idea

Sometimes a task describes *functionality*, not an exact package name — "something that blocks repeated failed SSH logins," not "install fail2ban." For that, `apt search` is the right first move:

```bash
apt search fail2ban
```

`apt search` (the friendlier front-end for the underlying `apt-cache search`) matches your keyword against both package *names* and their *description* text, case-insensitively. That's the important part: it surfaces relevant packages even when your keyword never appears in the literal package name, which is exactly the situation where you don't yet know what to type into `apt install`.

If you already know part of the exact name and want a narrower, name-only match, `apt list` accepts a glob pattern instead:

```bash
apt list 'fail2ban*' 2>/dev/null
```

Keep these two purposes distinct: `search` is for "I don't know the exact name," `list` with a pattern is for "I know roughly how it's spelled."

---

## Part II: Full Metadata, Without Installing Anything

Once you have a candidate name, `apt show` prints everything the package's control file declares — version, maintainer, dependencies, a longer description, installed and download size:

```bash
apt show nginx
```

This is purely a read against APT's local index cache. It changes nothing about what's installed, which makes it the right step to run before recommending or approving any install — reviewing a package's declared dependencies and footprint costs nothing and catches problems early.

---

## Part III: Installed vs. Candidate, and Which Repository Wins

`apt show` tells you about a package in the abstract. `apt-cache policy` tells you about a package's relationship to *this specific system, right now*:

```bash
apt-cache policy nginx
```

```text
nginx:
  Installed: (none)
  Candidate: 1.24.0-2ubuntu7
  Version table:
     1.24.0-2ubuntu7 500
        500 http://archive.ubuntu.com/ubuntu jammy-updates/main amd64 Packages
```

The first two lines answer the two questions that matter most: `Installed:` is the version currently on the system (or `(none)`), and `Candidate:` is the version APT would install or upgrade to right now, given how every configured repository is currently prioritized. On the next plain `apt upgrade`, the `Candidate` version is what gets applied — assuming nothing holds the package back.

The indented "Version table" beneath it is where multiple sources get disambiguated. Each configured repository can legitimately offer its own build of a package sharing the exact same name — Ubuntu's own archive, a backports repository, a vendor's third-party line — and the numeric value next to each (higher wins) is APT's pinning priority, the mechanism that decides which source "wins" when more than one claims to have `nginx`. This is the command that answers, specifically, *which repository* a candidate would actually be pulled from — `apt show` never tells you that.

---

## Part IV: Listing What's Already There, by Pattern

Enumerating installed packages that match a naming pattern is a research task in its own right, and it comes up constantly — "what Python tooling is on this box," "which kernel packages are installed":

```bash
apt list --installed | grep '^python3-'
```

`apt list --installed` restricts output to currently-installed packages only, one per line, formatted as `name/repo,now version arch [installed]`. Anchoring the `grep` with `^` matters: it matches only names that *begin with* the prefix, rather than any package whose name or version string merely contains that substring somewhere in the middle — the difference between a precise answer and a noisy, half-wrong one.

The same `list` subcommand, with a different flag, answers "what's currently upgradable" — the exact preview step from the daily maintenance loop, usable here purely as a reporting question:

```bash
apt list --upgradable
```

---

## Part V: When to Reach for `dpkg -s` Instead

`apt show` and `apt-cache policy` both describe APT's *cache* of repository metadata — accurate, but only as fresh as the last `apt update`, and describing the *candidate*, not necessarily what's actually installed. For "what is genuinely on this system right now," the authoritative source is the local `dpkg` database itself:

```bash
dpkg -s nginx 2>/dev/null || echo "nginx not currently installed"
```

`dpkg -s` reads directly from that local database, independent of repository cache freshness. The two tools are complementary, not redundant: `apt show`/`apt-cache policy` answer "what's available"; `dpkg -s` answers "what's actually here." When a question is specifically about the installed state, and cache staleness could plausibly matter, `dpkg -s` is the more trustworthy answer of the two.

---

## Self-Check and Verification

Test your understanding before moving to the hands-on lab:
1.  **Search vs. Exact Match**: Why does `apt search fail2ban` find results a plain `apt show fail2ban-nonexistent-name` never could? *(Answer: `apt search` matches against both package names and description text, surfacing anything relevant by keyword, while `apt show`/`apt list` without a wildcard only match a literal, exact package name.)*
2.  **Two Version Numbers**: `apt-cache policy nginx` prints an `Installed:` line and a `Candidate:` line that differ. What does each mean, and which one applies the next time someone runs `apt upgrade`? *(Answer: `Installed:` is the version currently on the system; `Candidate:` is the version APT would apply right now given repository priorities — `Candidate` is what a plain upgrade would move to, unless the package is held.)*
3.  **Cache vs. Reality**: A colleague insists `apt show` might disagree with what's genuinely installed. When, and why, and what do you check instead? *(Answer: when the local index cache is stale relative to the actual repository, or when the real question is about the installed build specifically — `dpkg -s` reads the local `dpkg` database directly, independent of cache freshness.)*
