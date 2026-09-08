# Part 1 — Finding a package, and describing it

> Prerequisite: [module landing page](./course.md). Next: [Part 2 — What would provide this, and cross-referencing rpm](./course-02-provides-and-cross-referencing.md).

Installing something without first knowing what it is and what it needs is how systems accumulate surprises. This part is entirely read-only: finding a package by keyword, and pulling its full metadata — nothing is installed, removed, or upgraded.

## `dnf search` — keyword across name and summary

You have a rough idea, not a name: "something that blocks brute-force login attempts".

```bash
# shell: inside the rpmbox container
dnf search fail2ban
```

`dnf search` matches the keyword against package **names** and their **summary** text, surfacing hits even when the keyword is not in the literal name. For a wider net that also searches the longer description field:

```bash
dnf search all fail2ban
```

If you already suspect part of the real name and want a narrower, name-only match:

```bash
dnf list available 'fail2ban*'
```

Keep them distinct: `search` = "I do not know the name"; `list available '<glob>'` = "I know roughly how it is spelled".

## `dnf info` — full metadata for one package

```bash
dnf info httpd
```

Prints version, release, arch, size, **source repository**, license, and a long description — sourced entirely from `dnf`'s repository metadata cache. It installs and changes nothing. This is the direct analogue of `apt show` / `rpm -qip`, and the step to run before recommending or approving any install.

> [!WARNING]
> - **`dnf info <exact-name>` to discover a package** → it only matches a literal name. Use `dnf search <keyword>`.
> - **`dnf search` vs `dnf search all`** → plain `search` is name + summary; `search all` adds the long description. Use `all` when a plain search comes up empty.
> - **Reading `dnf info` as installed state** → it reports the repository cache's view, not what is on the box (Part 2, and `rpm -qi`).
> - **Stale cache** → `dnf info` is only as fresh as the last metadata refresh; `dnf --refresh info <pkg>` forces one.

> *`dnf search <keyword>` matches names and summaries (add `all` for the long description); `dnf list available '<glob>'` matches names; `dnf info <name>` prints one package's full metadata from the repo cache, changing nothing.*

## Reference

- `man dnf` — `search`, `search all`, `list`, `info`; the glob syntax `list` accepts.
- `man dnf` — `--refresh` to force a metadata refresh before a read.
- `dnf repoquery` — the more powerful, scriptable metadata query tool for deeper research.
