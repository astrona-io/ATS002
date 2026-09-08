# Part 2 — Installed vs. candidate, and which source wins

> Prerequisite: [Part 1 — Finding a package, and describing it](./course-01-finding-and-describing.md). Next: [Section 050 quiz](../quiz.md).

`apt show` describes a package in the abstract. This part is the commands that describe a package's relationship to *this* system right now: which version is installed, which one would be applied next, which repository it would come from, and how to enumerate what is already here by pattern.

## `apt-cache policy` — the system-specific view

```bash
# shell: any host, unprivileged
apt-cache policy nginx
```

```text
nginx:
  Installed: (none)
  Candidate: 1.24.0-2ubuntu7
  Version table:
     1.24.0-2ubuntu7 500
        500 http://archive.ubuntu.com/ubuntu jammy-updates/main amd64 Packages
     1.24.0-1~jammy 500
        500 https://vendor.example.com/nginx/ubuntu jammy/main amd64 Packages
```

- **`Installed:`** — the version on the system now, or `(none)`.
- **`Candidate:`** — the version a plain `apt install` / `apt upgrade` would apply right now, given current repository priorities. Unless the package is held, this is what the next upgrade moves to.
- **Version table** — every available version, its **priority** (the `500`; higher wins, ties go to the higher version), and the **exact repository and version string** of each. This is the only command that tells you *which repository* a candidate would be pulled from — `apt show` never does.

Two repositories legitimately offering the same name (Ubuntu's archive and a vendor's line) both appear here; the priority column resolves the tie.

## Enumerate what is installed, by pattern

```bash
apt list --installed | grep '^python3-'
```

`apt list --installed` restricts output to currently-installed packages, one per line: `name/repo,now version arch [installed]`.

Anchoring the grep with **`^`** matters: it matches only names that *begin with* the prefix, not any package whose name or version string merely contains that substring. `^python3-` is a precise answer; `python3-` (unanchored) is a noisy, half-wrong one.

The same subcommand answers "what is upgradable" (the Module 3 preview, usable here as a report):

```bash
apt list --upgradable
```

## When to trust `dpkg -s` instead

`apt show` and `apt-cache policy` describe APT's **cache** of repository metadata — accurate only as of the last `apt update`, and describing the *candidate*. For "what is genuinely installed on this system right now", the authoritative source is the local `dpkg` database:

```bash
dpkg -s nginx 2>/dev/null || echo 'nginx not installed'
```

`dpkg -s` reads that database directly, independent of cache freshness. The tools are complementary: `apt show` / `apt-cache policy` answer "what is available"; `dpkg -s` answers "what is actually here". When the question is specifically about installed state and cache staleness could matter, `dpkg -s` is the more trustworthy of the two.

> [!WARNING]
> - **Expecting `apt show` to name the source repository** → it does not; `apt-cache policy` does, in the version table.
> - **`grep 'python3-'` without `^`** → matches `libpython3-...`, `...python3-doc` mid-string, and version strings. Anchor it.
> - **Trusting `apt-cache policy` on a system with a stale index** → `Candidate` reflects the last `apt update`. Run `apt update` first, or use `dpkg -s` for installed state.
> - **`apt list --installed` output fed straight to another command** → the `name/repo,...` format needs `cut -d/ -f1` first (Module 5).

> *`apt-cache policy <pkg>` is the system-specific view — Installed, Candidate, and a priority-ranked version table naming each source repository — while `apt list --installed | grep '^prefix'` enumerates what is here and `dpkg -s` is the cache-independent truth for installed state.*

## Reference

- `man apt-cache` — `policy`: Installed / Candidate, priorities, the version table.
- `man apt_preferences` — how priorities are assigned and changed by pinning.
- `man dpkg-query` — `-s` / `--status`, `-W --showformat` for exact installed-state queries in scripts.
