# Chapter 3: APT Basic Package Operations

Third-party repositories and standalone `.deb` files are the exception. The overwhelming majority of your time with Debian and Ubuntu package management is spent in one much more ordinary loop: find out what's new, apply it, install one more thing, retire something you no longer need. That loop is `apt update`, `apt upgrade`, `apt install`, and `apt remove`/`apt purge`. It sounds simple, and mechanically it is — but it's also the single most common source of avoidable mistakes in this entire domain, almost entirely because two of its verbs sound alike and do completely different things.

In this chapter we walk that loop exactly as you'd run it on a real maintenance window: refresh, preview, apply, install, retire, clean up.

---

## Part I: `apt update` Changes Nothing You Have Installed

Say this sentence out loud once, because it is worth having reflexively correct before you ever touch a production system under time pressure: **`apt update` does not install, upgrade, or remove a single package.**

```bash
sudo apt update
```

What it actually does is re-download the package *index* — the list of what's available and at what version — from every repository configured in `/etc/apt/sources.list` and `/etc/apt/sources.list.d/*`. Think of it as refreshing a store's printed catalog, not buying anything from it. Skip this step and every command that follows operates on a potentially stale view of the world: `apt upgrade` might miss a genuinely available update, and `apt install somepackage` might fail to find a package that was published to the repository five minutes ago.

`apt upgrade`, by contrast, is the step that actually changes installed software. The two commands are one word apart and mean entirely different things — confusing them is, by a wide margin, the most common mistake in this competency.

---

## Part II: Previewing Before You Commit

Before applying anything, ask what *would* change:

```bash
apt list --upgradable
```

This enumerates every installed package with a newer candidate version now available, changing nothing on the system in the process — a pure reporting step. Each line shows the package name, the new candidate version, and, in brackets, the version currently installed, so you can see exactly what's about to move before you commit to moving it.

---

## Part III: Applying Upgrades — and the "Kept Back" List

```bash
sudo apt upgrade
```

`apt upgrade` installs the newer version of every currently-installed package that *can* be upgraded without also installing or removing some other package. That restriction is deliberate: plain `upgrade` refuses to change the installed package *set*, only versions within it, which keeps its behavior predictable.

Sometimes the output ends with a line like `The following packages have been kept back:`. That means satisfying one of those packages' upgrades would require adding a new dependency or dropping an obsolete one — something plain `upgrade` won't do on its own. If, after reviewing what's listed, you've confirmed the add/remove is expected and safe, the more aggressive sibling handles it:

```bash
sudo apt full-upgrade
```

`apt full-upgrade` (the same operation as the older `apt-get dist-upgrade`) is explicitly willing to add or remove packages to complete upgrades that plain `upgrade` wouldn't attempt. Reach for it deliberately, once you understand why something was kept back — not reflexively, as a first choice, on a system you don't know well.

---

## Part IV: Installing Something New

```bash
sudo apt install fail2ban
```

A plain `apt install` resolves the named package's dependencies against the index refreshed in Part I and installs everything needed in one transaction. For a single, routine addition to the system, no extra flags are required.

---

## Part V: Remove vs. Purge — the Distinction That Actually Matters

Retiring a package is where a second, equally consequential distinction shows up. Suppose `ftp` is no longer needed anywhere on this host.

```bash
sudo apt remove ftp
```

This removes the package's binaries — but files under `/etc` that the package marked as configuration (its "conffiles") are deliberately left behind, in case the package gets reinstalled later and the same configuration should still apply.

```bash
sudo apt purge ftp
```

`purge` does everything `remove` does, and additionally deletes those leftover configuration files. The practical difference only shows up later: after a plain `remove`, a future reinstall can silently pick up old configuration nobody remembers leaving behind; after `purge`, a reinstall starts from the package's shipped defaults, with nothing left over from before.

If a task's wording includes "completely remove," "including configuration," or "clean reinstall," that is your cue: it means `purge`, not plain `remove`. A package removed but not purged shows up in `dpkg -l` with the status code `rc` — **r**emoved, **c**onfig files remain — a half-clean state worth recognizing on sight.

---

## Part VI: Orphaned Dependencies Don't Clean Themselves Up

Removing (or purging) `ftp` itself does not touch any dependency package that `ftp` alone pulled in. If nothing else on the system needs that dependency anymore, it just sits there, installed and unused, until something explicitly asks about it:

```bash
sudo apt autoremove
```

`apt autoremove` identifies every package that was installed automatically as a dependency of something else, and that nothing currently installed still depends on, and removes it. This is a distinct, deliberate follow-up step — never assume a `remove`/`purge` cascades to orphaned dependencies on its own. A task implying full cleanup that doesn't end in `autoremove` is an incomplete answer.

---

## Part VII: `apt` Versus `apt-get`/`apt-cache` — Know Both, Use Each Correctly

Everything above used `apt`, the modern, friendlier combined front-end. It's the right default for interactive, day-to-day administration. But open its own manual page:

```bash
man apt
```

`apt` explicitly documents its command-line interface and output as *not* guaranteed stable across versions — it's built for a human reading a terminal, complete with a progress bar and colorized output, and free to change between releases. `apt-get` and `apt-cache`, the older split tools `apt` was built to unify, carry no such warning; their behavior and output are stable, long-standing, and exactly why scripts, Ansible playbooks, and CI pipelines still reach for them instead of `apt` even today. Nothing about `apt-get`/`apt-cache` is deprecated — they remain the correct choice specifically when a result needs to be unattended or machine-parsed. Use `apt` at the keyboard; use `apt-get`/`apt-cache` in anything you're not there to watch run.

---

## Self-Check and Verification

Test your understanding before moving to the hands-on lab:
1.  **Update vs. Upgrade**: In one sentence, what does `apt update` change about the currently installed packages? *(Answer: nothing — it only refreshes APT's local index of what each configured repository currently offers; installing, upgrading, and removing packages are separate, later steps.)*
2.  **Kept Back**: `apt upgrade` reports a package "kept back." What does that mean, and which command is built to handle it? *(Answer: upgrading that package would require adding or removing some other package, which plain `upgrade` refuses to do on its own; `apt full-upgrade` — equivalently `apt-get dist-upgrade` — is willing to make that add/remove to complete the upgrade.)*
3.  **Remove vs. Purge**: A task says "fully remove the package, including its configuration, so a future reinstall starts clean." Which command satisfies that, and what would the other one have left behind? *(Answer: `apt purge`; plain `apt remove` would have left the package's conffiles under `/etc` in place, which a later reinstall could silently pick back up.)*
