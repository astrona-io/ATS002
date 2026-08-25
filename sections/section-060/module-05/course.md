# Chapter 5: DNF Package Groups

So far every install in this section has named one package at a time (or let `dnf`'s dependency solver quietly pull in whatever a single named package needed). That's fine for a monitoring agent or a single missing library, but "give this build server a full development toolchain" is a different kind of request — dozens of packages, installed and later retired together, as one coherent unit. APT has no first-class answer to that: an APT-based system fakes it with a hand-picked list of package names and, at best, a naming-pattern grep after the fact. `dnf` has a real answer, because RHEL-family repository metadata itself carries the concept: a **group** is a named, versioned set of packages — with its own mandatory, default, and optional membership tiers — published by the repository maintainer, not assembled by you from memory.

This chapter walks discovering what groups a system's repositories actually offer, inspecting one's real membership before committing to it, installing it, confirming what landed, and removing it cleanly — including the one removal detail that trips people up: what "remove the group" does and does not do to a package that happened to already be on the system for an unrelated reason.

---

## Working In This Lab: The `rpmbox` Container

Same arrangement as every earlier chapter — bootstrap has already installed Docker on the Ubuntu VM and started the long-lived, privileged Rocky Linux 9 container named `rpmbox`, with working repo metadata. Do all of this chapter's work inside it:

```bash
docker exec -it rpmbox bash
```

---

## Part I: Discovering What Groups Actually Exist

```bash
dnf group list
```

This lists every group visible by default from all currently enabled, configured repositories, split into "Installed Groups" and "Available Groups." Crucially, this is not a guess or a naming convention — it's genuine repository-published metadata (the older "comps" XML format `dnf` inherited), present independently of anything currently installed on this system.

Some groups a repository defines aren't surfaced by that plain listing at all — usually internal or less commonly needed ones, hidden to avoid cluttering everyday output:

```bash
dnf group list --hidden
```

Reach for `--hidden` any time a group you'd expect to exist doesn't show up in the plain listing before concluding it isn't published at all.

---

## Part II: Inspecting Real Membership Before Committing

Never install a group blind. Before touching anything:

```bash
dnf group info "Development Tools"
```

This prints the group's description, then three clearly separated sections: **Mandatory Packages**, **Default Packages**, and **Optional Packages**. The distinction matters for predicting exactly what a plain install does:

* **Mandatory** — always installs as part of the group; cannot be excluded from a "with all mandatory members" install.
* **Default** — installs by default, but can be explicitly excluded.
* **Optional** — a genuine member of the group for completeness and discoverability, but does **not** install automatically with a plain group install. It has to be named explicitly, or the group installed with `--with-optional`.

That third tier is the one most people get wrong under pressure: seeing a package listed under "Optional Packages" and assuming a plain group install will bring it along anyway.

---

## Part III: Installing the Group

```bash
sudo dnf group install "Development Tools"
```

This resolves and installs every mandatory and default member as one transaction — the practical equivalent of typing every one of those package names into a single `dnf install` call by hand, except the membership list came from repository metadata you already inspected in Part II, not from memory. To also pull in optional members:

```bash
sudo dnf group install "Development Tools" --with-optional
```

`--with-optional` is never the default — optional members are deliberately excluded unless you ask for them explicitly.

---

## Part IV: Confirming What Actually Landed

```bash
dnf group info "Development Tools"
```

Run the exact same inspection command from Part II again. Post-install, each currently-installed member is marked with an installed-indicator next to its name, letting you visually confirm the mandatory/default set landed and see at a glance whether any optional members are also present.

```bash
dnf group list installed
```

This filters the group listing down to groups `dnf` currently considers installed — the group-level analog of `dnf list installed` for individual packages. `"Development Tools"` should now appear in it.

---

## Part V: Removing a Group Cleanly — And What That Really Means

```bash
sudo dnf group remove "Development Tools"
```

Read that command's actual semantics carefully before running it on anything you care about: by default, `dnf` removes packages it tracked as having been installed **specifically as part of this group installation** — not every package the group's metadata happens to list as a member.

That distinction has a very concrete consequence. Suppose `automake` was already installed on this host beforehand, for a completely unrelated reason, before the group install in Part III ever ran. `automake` also happens to be a member of `"Development Tools"`. Removing the group afterward does **not** remove `automake` — `dnf`'s own tracking, not raw membership overlap, is what determines removal. A package that was present before the group install is treated as independently owned, group or no group. If that package genuinely needs to go too, it takes a separate, explicit `dnf remove automake` — group removal is not the right tool for a package it didn't itself install.

The inverse holds just as cleanly: a package that genuinely was pulled in *because of* the group install — say `gcc`, freshly installed in Part III and not present before it — is removed by the group removal, because `dnf` tracked it as belonging to that transaction.

---

## Part VI: Auditing Currently-Present Groups

```bash
dnf group list installed
```

Confirm `"Development Tools"` no longer appears among installed groups after Part V. This is the same audit command from Part IV, just run again after removal — the group-level equivalent of double-checking `rpm -q` after an individual package removal.

---

## Self-Check and Verification

1. **Three Tiers**: A package is listed under a group's "Optional Packages" section. Does a plain `dnf group install "<group>"` bring it in? *(Answer: No — optional members are deliberately excluded unless named explicitly or `--with-optional` is passed.)*
2. **Before You Look, or After?**: Which command shows you exactly what a group install would bring in, without installing anything? *(Answer: `dnf group info "<group>"` — a pure read against repository metadata.)*
3. **The Tracking Trap**: `automake` was installed independently before `"Development Tools"` was ever installed on this host. After `dnf group remove "Development Tools"`, is `automake` gone? *(Answer: No — `dnf` only removes what it tracked as installed *because of* that specific group transaction; a package present beforehand for an unrelated reason survives the group removal even though it's also a group member.)*
4. **Hidden Groups**: `dnf group list` doesn't show a group you were told exists. What's the next command to try before concluding it isn't published at all? *(Answer: `dnf group list --hidden`.)*
