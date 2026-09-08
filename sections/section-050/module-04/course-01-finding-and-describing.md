# Part 1 — Finding a package, and describing it

> Prerequisite: [module landing page](./course.md). Next: [Part 2 — Installed vs. candidate, and which source wins](./course-02-installed-vs-candidate.md).

"It installed without an error" and "it is the version and source I expected" are different claims. Before committing to any change there is a read-only layer of `apt` tooling whose only job is to answer questions. This part is finding a package when you only have a rough idea, and reading everything its metadata declares — without touching the system.

## `apt search` — keyword across name *and* description

A task often describes *function*, not a package name: "something that blocks repeated failed SSH logins", not "install fail2ban".

```bash
# shell: any host, unprivileged
apt search fail2ban
```

`apt search` (front-end for `apt-cache search`) matches the keyword against both package **names** and their **description text**, case-insensitively. That is the point: it surfaces the right package even when your keyword is not in the literal name — exactly when you do not yet know what to type into `apt install`.

For a narrower, **name-only** match when you already know roughly how it is spelled:

```bash
apt list 'fail2ban*' 2>/dev/null
```

`apt list` with a shell glob matches package names only. Keep the two distinct: `search` = "I do not know the exact name"; `list <pattern>` = "I know the spelling roughly".

## `apt show` — full declared metadata

Once you have a candidate name:

```bash
apt show nginx
```

Prints everything the package's control stanza declares — version, maintainer, `Depends:` / `Recommends:` / `Suggests:`, the long description, installed size, download size. It is a pure read against APT's **local index cache** — changes nothing. Review a package's declared dependencies and footprint here before recommending or approving an install; it costs nothing and catches problems early.

`apt show` describes the package **in the abstract** — it does not tell you what is installed on *this* system or which repository a version would come from. That is Part 2.

> [!WARNING]
> - **`apt show <exact-name>` to discover a package** → it only matches a literal name. Use `apt search <keyword>` when you do not know the name.
> - **`apt list` without a pattern** → lists (almost) everything. Give it a glob (`'php8.1-*'`) or `--installed`.
> - **Reading `apt show` as the installed state** → it reports the cached candidate's metadata, not what is on the box (Part 2, and `dpkg -s`).
> - **Stale cache** → `apt show` is only as fresh as the last `apt update`.

> *`apt search <keyword>` matches names and descriptions (use it when you do not know the name); `apt list '<glob>'` matches names only; `apt show <name>` prints the cached metadata for one package in the abstract, changing nothing.*

## Reference

- `man apt` — `search`, `list`, `show`; the glob syntax `list` accepts.
- `man apt-cache` — `search` (the backend), `showpkg`, `depends` / `rdepends`.
- `man apt` — the note that `apt`'s output is for humans; use `apt-cache` for scripts.
