# Chapter 2: dpkg Low-Level Package Management

When `apt install` finishes, a quieter tool did the actual work: `dpkg` unpacked the files and registered them in a local database. `apt` is the network-and-dependency layer; `dpkg` is the one-file-at-a-time installer with no concept of the internet or a repository. Most days you never call it directly — until someone hands you a standalone `.deb`, or a system's package state is left inconsistent by an interrupted install. This module operates at that lower level: inspect a `.deb` before trusting it, install it, ask ownership questions in both directions, and recover a package that is neither cleanly installed nor absent.

Three short parts; work them in order.

## How this module is organised

1. **[Part 1 — What `dpkg` knows, and inspecting a `.deb` before you trust it](./course-01-dpkg-scope-and-inspecting-a-deb.md)** — the "one thing at a time, no repository" model, and `dpkg -I` / `dpkg -c` as read-only inspections of a `.deb` file.
2. **[Part 2 — Installing directly, and ownership queries in both directions](./course-02-installing-and-ownership-queries.md)** — `dpkg -i` and the `apt --fix-broken install` reflex for a missing dependency, then `-S` (file → package), `-L` (package → files), and the file-path-vs-package-name flag map.
3. **[Part 3 — Status codes and recovering an interrupted package](./course-03-status-codes-and-recovery.md)** — reading the `dpkg -l` status column (`ii`, `iU`, `iF`, `rc`), what an interruption leaves behind, and `dpkg --configure -a` followed by `apt --fix-broken install`.

## Learning objectives

After this module you can:

- **State** what `dpkg` operates on and what it cannot do, and explain why `dpkg -i` cannot resolve a missing dependency.
- **Inspect** a `.deb` file's metadata (`dpkg -I`) and its file list (`dpkg -c`) without changing the system.
- **Install** a standalone `.deb` and complete it with `apt --fix-broken install` when a dependency is missing.
- **Map** a file to its owning package (`dpkg -S`) and a package to its files (`dpkg -L`), and keep the file-path vs package-name flags straight.
- **Read** the `dpkg -l` status column and identify a package left mid-install versus one cleanly installed or removed.
- **Recover** an interrupted package with `dpkg --configure -a` plus `apt --fix-broken install`.

## Before you start

Assumed: a Linux shell, `sudo`, and Module 1's `apt` basics. Every command block states the shell and privilege it assumes; the `.deb` examples use a placeholder path.

## Where this fits

This module is the layer beneath the everyday `apt` loop that follows it. The status-code reading and the `dpkg --configure -a` / `apt --fix-broken install` recovery are exactly what the section capstone tests when it hands you a system whose package state was left half-finished.
