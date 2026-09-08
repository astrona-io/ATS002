# Part 1 — `apt update` is not `apt upgrade`

> Prerequisite: [module landing page](./course.md). Next: [Part 2 — Applying upgrades, and installing](./course-02-applying-upgrades-and-installing.md).

Two verbs one word apart do completely different things, and confusing them is the most common mistake in this competency. This part settles what `apt update` actually touches (nothing you have installed), why skipping it makes every later command act on a stale view, and the pure-reporting preview step.

## `apt update` refreshes the index — and only that

```bash
# shell: host, root
sudo apt update
```

Say it once, out loud, so it is reflexive under pressure: **`apt update` does not install, upgrade, or remove a single package.**

What it does: re-download the **package index** — the list of what each repository currently offers, and at what version — from every source in `/etc/apt/sources.list` and `/etc/apt/sources.list.d/*`. It also verifies each index's signature (Module 1).

As an analogy (flagged): `apt update` refreshes a store's printed catalogue. It buys nothing. Where it breaks down: a paper catalogue is obviously just paper; a stale APT index looks identical to a fresh one until an install fails or an available update is missed.

Skip it and:

- `apt upgrade` can miss an update that is genuinely available.
- `apt install newpkg` can fail to find a package published minutes ago.
- `apt-cache policy` shows yesterday's candidate versions.

## Preview what would change

Before applying anything, a read-only question:

```bash
apt list --upgradable
```

```text
Listing...
curl/jammy-updates 7.81.0-1ubuntu1.15 amd64 [upgradable from: 7.81.0-1ubuntu1.13]
openssl/jammy-security 3.0.2-0ubuntu1.12 amd64 [upgradable from: 3.0.2-0ubuntu1.10]
```

Every installed package with a newer candidate now available. Each line: name, the new candidate version, and in brackets the version installed now. Nothing changes — it is a report. Run it after `apt update` and before `apt upgrade` to see exactly what is about to move.

> [!WARNING]
> - **`apt update` mistaken for `apt upgrade`** → `update` never changes installed software; `upgrade` does. They are different operations.
> - **Running `apt install` / `apt upgrade` without a recent `apt update`** → decisions are made against a stale index; a genuinely available package or update can appear missing.
> - **Reading `apt list --upgradable` as an action** → it changes nothing; it is the preview.

> *`apt update` only re-downloads the package index from each configured repository — it installs, upgrades, and removes nothing; run it before every session so `apt list --upgradable` and every later command see the current state.*

## Reference

- `man apt` — `update`, `list --upgradable`; the note that `apt`'s CLI/output is not guaranteed stable (Part 3).
- `man 5 sources.list` — the files `apt update` reads to know which indexes to fetch.
- `man apt-get` — `update` in the stable-interface tool, for scripts.
