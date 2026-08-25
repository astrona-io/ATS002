# Chapter 4: DNF Package Information Lookup

Installing something without first knowing what it actually is, what it depends on, and — often the more interesting question on an RPM system — which package would even provide the file or command you're trying to satisfy, is how production systems end up with surprises. This chapter is entirely read-only: nothing gets installed, removed, or upgraded. Every step here answers a research question using local tools, before any hypothetical action would be taken.

---

## Working In This Lab: The `rpmbox` Container

Same arrangement as the earlier chapters — bootstrap has already installed Docker on the Ubuntu VM and started a long-lived, privileged Rocky Linux 9 container named `rpmbox` with working repo metadata. Do all of this chapter's research inside it:

```bash
docker exec -it rpmbox bash
```

Since this chapter is read-only, the lab will ask you to save the output of a few specific lookups into files under `/home/candidate/answers/` inside the container, so your research has a concrete, checkable record — see the lab's `docs/question.md` for the exact filenames expected.

---

## Part I: Finding a Package by Keyword

Suppose you only have a rough idea of what you're looking for — "something that blocks brute-force login attempts" — not an exact package name:

```bash
dnf search fail2ban
```

`dnf search` matches against both package *names* and their *summary* description text, surfacing relevant hits even when the keyword isn't literally part of the package name. For a broader net that also checks the longer description field:

```bash
dnf search all fail2ban
```

If you already suspect part of the actual name and want a narrower, name-only match instead:

```bash
dnf list available 'fail2ban*'
```

---

## Part II: Pulling Full Metadata for One Package

```bash
dnf info httpd
```

This prints the package's full metadata — version, release, architecture, size, source repo, license, and a longer description — sourced entirely from dnf's repository metadata cache. It does not install, remove, or otherwise touch anything about what's actually on the system. This is the direct dnf analog of `apt show`/`rpm -qip`, and exactly the step to run before recommending or approving any install.

---

## Part III: Finding What Would Provide an Uninstalled File or Command

This is genuinely one of dnf's most useful day-to-day capabilities, and it answers a question `rpm -qf` structurally cannot: "what package would I need to install to get this file or command?"

```bash
dnf provides /usr/sbin/ip
```

`dnf provides` (aliased as `dnf whatprovides`) searches every configured repository's metadata for any package that declares it would place a file at that path, or declares a matching capability — entirely independent of whether anything is currently installed. Contrast this with `rpm -qf`, covered in Chapter 1, which only ever searches the *local, installed* database — it structurally cannot answer "what would I need to install," only "what already-installed thing owns this."

If you're not certain of the exact install path (`/usr/bin` vs `/usr/sbin`, symlinked or not):

```bash
dnf provides '*/ip'
```

The leading `*/` glob matches any directory prefix, finding the providing package regardless of exactly where the binary ends up — more robust than guessing a precise path when you only know the command's name.

---

## Part IV: Listing Installed Packages by Pattern

```bash
dnf list installed | grep '^python3-'
```

Anchoring with `^` ensures the match is against the *start* of the package-name column, not anywhere the string might appear (a version string, a repo name). Far faster and less error-prone than listing everything and scanning by eye.

---

## Part V: When to Cross-Reference rpm Instead

`dnf info`/`dnf provides` reflect dnf's *repository metadata cache*, which needs network access (or at least a populated local cache) and could theoretically be stale if not recently refreshed. `rpm -qi`/`rpm -qf` — covered in Chapter 1 — read directly from the local RPM database: zero network dependency, always exactly what's on this system right now. The two are complementary, not redundant. Reach for `dnf` when the question is "what's available out there"; reach for `rpm` when the question is specifically "what's actually installed here."

---

## Self-Check and Verification

1. **Search vs. List**: What's the difference between what `dnf search keyword` matches against versus `dnf list <pattern>*`? *(Answer: `search` matches names *and* summary text; `list` matches names against a glob pattern only.)*
2. **The Structural Gap**: Why can `dnf provides` answer "what provides `/usr/sbin/ip`" even for a completely uninstalled package, when `rpm -qf` cannot? *(Answer: `dnf provides` searches repository metadata, present for every configured repo regardless of local install state; `rpm -qf` only searches the local database of what's already installed.)*
3. **Does It Touch Anything?**: Does running `dnf info httpd` change anything about what's installed on the system? *(Answer: No — it's a pure read against the metadata cache.)*
