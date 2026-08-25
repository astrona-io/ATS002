# Chapter 3: DNF Basic Package Operations

Before touching package groups or dependency introspection, LFCS expects rock-solid fluency with the everyday `dnf` lifecycle on RHEL/Fedora-family systems: checking what's upgradable, applying upgrades, installing something new, and fully retiring something no longer needed. `dnf` folds metadata refresh into most of its commands automatically, which changes the mental model slightly from APT's explicit two-step `update`/`upgrade` split — and `dnf` has a feature APT has no real equivalent for at all: a genuinely transactional history that can undo an entire past operation as a unit, not just individual packages.

---

## Working In This Lab: The `rpmbox` Container

Same arrangement as the previous two chapters — this repo's only VM image is Ubuntu 24.04, so bootstrap installs Docker on the VM and starts a long-lived, privileged Rocky Linux 9 container named `rpmbox`. Do all of this chapter's work inside it:

```bash
docker exec -it rpmbox bash
```

One extra detail for this chapter specifically: `fail2ban` isn't in Rocky's default BaseOS/AppStream repositories at all — it's an EPEL (Extra Packages for Enterprise Linux) package, the standard, first-party-adjacent extra repository almost every real RHEL/Rocky server enables sooner or later. Bootstrap has already enabled EPEL inside `rpmbox` for you, so `dnf install fail2ban` will work exactly as this chapter describes. Worth remembering for the real exam: if a package doesn't turn up in a normal search, checking whether it needs EPEL is a very common next step.

---

## Part I: Checking What's Upgradable, Without Applying Anything

```bash
dnf check-update
```

This lists every installed package with a newer version currently available in configured repos, exiting with a distinct status code (`100`) when updates are found versus `0` when none are — scripts can key off that. Nothing changes as a result of running this; it's the reporting step you run before committing to anything.

Notice what's different from APT here: `dnf` generally keeps its metadata cache reasonably current across most subcommands automatically, refreshing it when the local cache is judged stale. There's no separate "did you remember to `apt update` first" step to forget.

---

## Part II: Applying the Upgrades

```bash
sudo dnf upgrade
```

This installs the newer version of every currently-installed package that has one available, letting dnf's dependency solver work out any necessary related changes as part of the same transaction. Unlike APT's `upgrade`/`full-upgrade` split, there is normally no separate "more aggressive" dnf command needed for routine upgrades — dnf presents one plan and applies it. (`dnf upgrade` and the older `dnf update` are synonyms; `upgrade` is the currently preferred spelling.)

---

## Part III: Installing and Removing

```bash
sudo dnf install fail2ban
```
A plain `dnf install` resolves and installs `fail2ban` plus any dependencies it needs.

```bash
dnf list installed | grep telnet
sudo dnf remove telnet
```
Confirm a package is actually installed and note its exact name before removing it. One genuinely different mechanism from Debian's remove/purge split is worth calling out here: RPM marks certain files a package ships as `%config`. On removal, RPM checks each `%config` file individually — if it's unchanged since install, it's deleted along with the rest of the package; if it was modified, RPM renames it with a `.rpmsave` suffix instead of deleting it. This is a per-file, automatic decision based on whether the file was actually touched, not a binary choice tied to which top-level command you typed.

```bash
sudo dnf autoremove
```
Removing `telnet` itself never automatically cascades to whatever dependency packages it pulled in that nothing else still needs — `autoremove` is the separate, deliberate follow-up step that cleans those up. Skipping it is an easy, gradeable miss.

---

## Part IV: DNF's Standout Feature — Transactional History

Here's the capability that genuinely sets `dnf` apart from APT: a transaction log that can undo an *entire past operation* as a single unit.

```bash
dnf history
```
Lists every transaction dnf has performed on this system, most recent first, each with an ID, a short description, and a package count.

```bash
dnf history info <id>
```
Expands one specific transaction to show exactly which packages were installed, upgraded, or removed as part of it.

Suppose a routine install accidentally bundled in something unrelated — a common real mistake, and a good deliberate drill: `sudo dnf install fail2ban some-unwanted-package` in one command, more than you meant to touch in a single transaction.

```bash
sudo dnf history undo <id>
```
This computes and applies the exact inverse of everything that transaction did — reverting the unwanted package *and* uninstalling `fail2ban` — as one atomic operation. Compare that to trying to hand-reconstruct "what changed, and did I re-remove everything that got installed" package by package: `history undo` does this mechanically and reliably from dnf's own recorded transaction data, which manual reconstruction cannot match for anything beyond a single-package transaction.

```bash
sudo dnf install fail2ban
```
With the mixed transaction fully undone, this repeats the install in isolation — a clean, single-purpose transaction with nothing unrelated bundled in.

(`dnf history redo <id>` exists too, for the opposite situation: reapplying a transaction, including one you just undid, if the undo itself turns out to have been the wrong call.)

---

## Self-Check and Verification

1. **Config Files on Removal**: After `dnf remove somepkg`, is a `%config` file it shipped always deleted, always kept, or something more conditional? *(Answer: conditional, per-file — deleted if unchanged since install, renamed to `.rpmsave` if it was modified.)*
2. **Orphan Cleanup**: Does `dnf remove telnet` also remove a dependency package that only `telnet` needed? *(Answer: No — that requires a separate, explicit `dnf autoremove`.)*
3. **The Standout Feature**: A transaction bundled an unwanted change in with something you actually wanted. What's the single most reliable way to reverse just that transaction? *(Answer: `dnf history undo <id>` — it reverses the exact recorded set of changes as one atomic unit, rather than manually re-deriving what changed.)*
