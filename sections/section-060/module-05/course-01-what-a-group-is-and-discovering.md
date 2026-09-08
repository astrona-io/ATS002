# Part 1 — What a group is, and discovering what exists

> Prerequisite: [module landing page](./course.md). Next: [Part 2 — Inspecting membership, and installing](./course-02-inspecting-and-installing.md).

"Install one package" and "give this server a full development toolchain" are different kinds of request. `dnf` answers the second with a real, first-class concept — a **group** — that APT has no equivalent for. This part is what a group actually is and how to see the ones a system's repositories publish.

## A group is repository-published metadata

A **group** is a named set of packages, with its own membership tiers, **published by the repository maintainer** in the repo's metadata (the "comps" XML format `dnf` inherited from `yum`). It is not a naming convention you grep for, and not a list you assemble from memory — it is data that ships with the repository, present independently of anything installed on your system.

APT's nearest move is a hand-picked list of package names plus a `grep` after the fact; `dnf group` is the genuine article.

## Discovering the groups that exist

```bash
# shell: inside the rpmbox container
dnf group list
```

Lists every group visible by default from all enabled repositories, split into **Installed Groups** and **Available Groups**.

Some groups a repository defines are **hidden** from that plain listing — usually internal or rarely-needed ones, kept out to reduce clutter:

```bash
dnf group list --hidden
```

Reach for `--hidden` any time a group you expect does not appear in the plain listing, before concluding it is not published at all.

(On newer `dnf`, `dnf group` and `dnf grouplist` / `dnf groupinfo` etc. are equivalent; the `dnf group <subcommand>` spelling is current.)

> [!WARNING]
> - **Assuming a group is "just a package-name prefix"** → it is repository-published comps metadata with defined tiers (Part 2), not a pattern.
> - **Concluding a group does not exist because `dnf group list` omits it** → try `dnf group list --hidden` first.
> - **Expecting APT to have the same feature** → it does not; a group is an RPM-family concept.

> *A `dnf` group is a maintainer-published, tiered set of packages in the repository's comps metadata; `dnf group list` shows the default ones and `dnf group list --hidden` reveals the rest.*

## Reference

- `man dnf` — `group list`, `group list --hidden`, `group summary`.
- Fedora packaging docs, "comps.xml" — the group metadata format and the mandatory/default/optional tiers.
- `dnf group list ids` — show the machine-readable group IDs alongside the display names.
