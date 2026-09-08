# Chapter 5: APT Package Groups & Bulk Operations

Real package management rarely happens strictly one package at a time. A toolchain arrives as a meta-package plus companions, installed together. A family of modules — every `php8.x-*`, every `linux-image-*` — needs to be found and acted on as a set. And when a group is genuinely interdependent, protecting only *some* of it from an upgrade can be worse than protecting none. This module is operating on packages in groups: one transaction, pattern discovery, and a bulk hold across a whole matched set in one auditable step.

Two short parts; work them in order.

## How this module is organised

1. **[Part 1 — One transaction, and finding a family by pattern](./course-01-one-transaction-and-finding-a-family.md)** — passing several packages to a single `apt install` so dependencies resolve as one set, and matching a family with `grep -E '^prefix'` (the `-E` and `^` details) then `cut -d/ -f1`.
2. **[Part 2 — Bulk actions across a matched set](./course-02-bulk-actions-across-a-set.md)** — `xargs` into one `apt-mark hold`, why a partial hold on an interdependent family is worse than no hold, and auditing with `apt-mark showhold`.

## Learning objectives

After this module you can:

- **Install** several related packages as one transaction and explain why that beats separate calls.
- **Match** a package family by naming pattern, escaping the literal dot and anchoring to the name start.
- **Convert** `apt list` output to bare package names with `cut -d/ -f1`.
- **Apply** a bulk `apt-mark hold` across a matched set with `xargs`.
- **Explain** why a partial hold on a genuinely interdependent family can be worse than no hold.
- **Audit** the result with `apt-mark showhold` rather than trusting the pipeline's exit code.

## Before you start

Assumed: a Linux shell, `sudo`, basic regex, and Modules 1–4 (`apt-mark hold`, `apt list --installed`). Every command block states the shell and privilege it assumes.

## Where this fits

This module combines the earlier ones — the hold from Module 1, the `apt list --installed` research from Module 4 — into a repeatable set operation. The section capstone protects an interdependent package family ahead of a risky upgrade, and expects the whole set held and verified, not just the members named in the brief.
