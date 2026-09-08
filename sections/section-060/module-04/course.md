# Chapter 4: DNF Package Information Lookup

Installing something without first knowing what it is, what it depends on, and — the more interesting question on an RPM system — which package would even provide the file or command you are trying to satisfy, is how systems end up with surprises. This module is entirely read-only: every step answers a research question using local tools, before any action.

Two short parts; work them in order.

## How this module is organised

1. **[Part 1 — Finding a package, and describing it](./course-01-search-and-describe.md)** — `dnf search` (name + summary) and `dnf search all` (long description), `dnf list available '<glob>'`, and `dnf info` for full metadata from the repo cache.
2. **[Part 2 — What would provide this, and cross-referencing `rpm`](./course-02-provides-and-cross-referencing.md)** — `dnf provides` answering "what would I install to get this file", the structural gap versus `rpm -qf`, listing installed packages by anchored pattern, and when `rpm -qi`/`-qf` is the more trustworthy answer.

## Learning objectives

After this module you can:

- **Find** a package by function with `dnf search` / `dnf search all`, and by rough name with `dnf list available`.
- **Read** a package's full metadata and source repository with `dnf info` without changing anything.
- **Answer** "what package provides this file or command" with `dnf provides`, including for uninstalled packages.
- **Explain** why `dnf provides` can answer that and `rpm -qf` cannot.
- **Enumerate** installed packages by anchored pattern, and choose `rpm -qi`/`-qf` when cache staleness matters.

## Before you start

Assumed: Modules 1–3 (`rpm` queries, `dnf` loop), a Linux shell. This repo's only VM is Ubuntu 24.04, so the lab runs a real Rocky Linux 9 container **`rpmbox`** with working repo metadata — `docker exec -it rpmbox bash`. Every command here is read-only.

## Where this fits

This is the "look before you leap" companion to the `dnf` action loop and the group operations that follow. `dnf provides` is the distinctively RPM-family tool the section leans on for "what would I need to install".
