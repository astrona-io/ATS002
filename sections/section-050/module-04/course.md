# Chapter 4: APT Package Information Lookup

"It installed without an error" and "it is the version and source I expected" are different claims, and conflating them is how systems accumulate quiet surprises — the wrong build, an unexpectedly old version, a package from a repository nobody meant to trust. Before you install, remove, or upgrade anything, a whole layer of `apt` tooling exists only to answer questions, entirely read-only. This module is that research layer — what you reach for *before* committing to a change.

Two short parts; work them in order.

## How this module is organised

1. **[Part 1 — Finding a package, and describing it](./course-01-finding-and-describing.md)** — `apt search` (keyword across name and description) vs `apt list '<glob>'` (name only), and `apt show` for the full declared metadata of one package in the abstract.
2. **[Part 2 — Installed vs. candidate, and which source wins](./course-02-installed-vs-candidate.md)** — `apt-cache policy` (Installed, Candidate, priority-ranked version table naming each repository), enumerating installed packages by anchored pattern, and when `dpkg -s` is the more trustworthy answer.

## Learning objectives

After this module you can:

- **Find** a package by function with `apt search`, and by rough name with `apt list '<glob>'`.
- **Read** a package's declared dependencies and footprint with `apt show` without changing the system.
- **Interpret** `apt-cache policy` — Installed, Candidate, priorities, and which repository a version comes from.
- **Enumerate** installed packages matching a prefix with an anchored `grep`.
- **Choose** `dpkg -s` over `apt show` / `apt-cache policy` when the question is about installed state and the cache may be stale.

## Before you start

Assumed: a Linux shell and Modules 1–3 (repositories, `dpkg` basics, the `apt` loop). Every command in this module is read-only; none changes installed software.

## Where this fits

This module is the "look before you leap" companion to Module 3's action loop and Module 5's bulk operations. `apt-cache policy` in particular is the command that ties the section together — it is how you confirm which repository and version any later action will actually touch.
