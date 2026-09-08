# Part 1 — The everyday `dnf` loop

> Prerequisite: [module landing page](./course.md). Next: [Part 2 — Removing, and transactional history](./course-02-removing-and-history.md).

`dnf` folds metadata refresh into most commands, so the mental model differs from APT's explicit `update` / `upgrade` split. This part is the routine loop — check, upgrade, install — and the ways it is *not* like `apt`.

## Check what is upgradable

```bash
# shell: inside the rpmbox container
dnf check-update
```

Lists every installed package with a newer version available in configured repos, and **exits `100`** when updates are found (vs `0` when none) — a script can key off that. Running it changes nothing.

The APT contrast: `dnf` generally keeps its metadata cache current across subcommands automatically, refreshing when the local cache is judged stale. There is no separate "did you `apt update` first" step to forget. (`dnf makecache` forces a refresh if you want one; `--refresh` on a command does the same for that run.)

## Apply the upgrades

```bash
sudo dnf upgrade
```

Installs the newer version of every installed package that has one, letting the dependency solver work out related changes **in the same transaction**. Unlike APT's `upgrade` / `full-upgrade` split, there is normally no separate "more aggressive" command for routine upgrades — `dnf` computes one plan and applies it.

`dnf upgrade` and the older `dnf update` are synonyms; `upgrade` is the current spelling.

## Install something new

```bash
sudo dnf install fail2ban
```

Resolves and installs `fail2ban` plus its dependencies. Several at once → one call with all the names.

A real-exam habit worth keeping: if a package does not show up, check whether it needs **EPEL** (Extra Packages for Enterprise Linux) — the standard extra repository most RHEL/Rocky servers enable. `fail2ban` is an EPEL package; `rpmbox` has EPEL enabled already.

> [!WARNING]
> - **Looking for a `dnf update` step before `dnf upgrade`** → `dnf` refreshes metadata automatically; `check-update` / `upgrade` do it for you.
> - **Expecting a `full-upgrade` equivalent** → `dnf upgrade` already presents and applies one complete plan, including add/removes the solver needs.
> - **Concluding a package "does not exist" because `dnf search` is empty** → check EPEL (`dnf install epel-release` on a real system; already enabled in `rpmbox`).
> - **Keying a script off `check-update`'s exit code without expecting `100`** → `100` means "updates available", not an error.

> *`dnf check-update` reports available updates (exit `100` when there are any) and `dnf upgrade` applies one solver-computed plan — no separate `update` step and no `full-upgrade` split, because `dnf` refreshes metadata itself.*

## Reference

- `man dnf` — `check-update` (and its exit codes), `upgrade` / `update`, `install`, `makecache`, `--refresh`.
- `man dnf.conf` — `metadata_expire` and how the automatic cache refresh is timed.
- Fedora/RHEL docs, "EPEL" — what it is and why so many packages live there.
