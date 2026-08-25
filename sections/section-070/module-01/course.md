# Zypper Basic Package Operations

Every package manager you have met so far in this domain — `apt`, `dpkg`, `dnf`, `rpm` — has taught you some version of the same story: refresh what the system knows about, then install, remove, or upgrade based on that knowledge. `zypper`, the package tool on openSUSE and SUSE Linux Enterprise, tells that same story with one extra chapter nobody else writes. Alongside "is there a newer version of this package," SUSE distributions also ask a second, separate question: "has the vendor published a *patch* that covers this system?" Those are not the same question, and confusing them is the single most common way an SUSE administrator either drifts out of policy or ships more change than a maintenance window intended.

Think of it like a hospital pharmacy. Every drug on the shelf quietly gets restocked with newer formulations over time — that's the raw, unglamorous version-bump reality of `zypper list-updates`. But a *recall notice* is different: it is a curated, tracked, often urgent bulletin naming exactly which batches are affected and why, issued deliberately by an authority who has reviewed the situation. That's `zypper list-patches`. A conservative pharmacy manager acts on recall notices immediately, but doesn't restock every shelf just because a slightly newer formulation exists. That distinction — recall notice versus routine restock — is exactly the distinction between `zypper patch` and `zypper update`.

---

## Working Inside the zypperbox Container

Before touching a single zypper command, you need to understand *where* you are actually working in this lab.

The virtual machine this lab boots is Ubuntu 24.04 — that is simply the only base image this training platform has available. openSUSE is not natively installable here. But `zypper` only exists, and only means something, on a genuine openSUSE package database. Faking it with a wrapper script would teach you nothing real and would actively mislead you before your exam.

So instead, bootstrap does something more honest: it installs Docker on the Ubuntu host, then starts a long-lived container from the official `opensuse/leap:15.6` image, named `zypperbox`:

```bash
docker run -d --name zypperbox --privileged opensuse/leap:15.6 sleep infinity
```

That container keeps running for your entire lab session. Inside it, `zypper` is not simulated in any way — it is the real openSUSE Leap 15.6 tool, backed by the real RPM database, talking to the real openSUSE package repositories over the internet, exactly as it would on a bare-metal or cloud openSUSE server. The only thing virtualized here is *where the disk lives* — the tool and the data behind it are authentic.

To do any work in this lab, you open a shell inside that container:

```bash
docker exec -it zypperbox bash
```

Everything from this point forward in this module — `zypper refresh`, `zypper list-updates`, `zypper install fail2ban`, all of it — happens inside that `docker exec` shell, not on the Ubuntu host itself. If you type `zypper` directly on the host, you'll get "command not found," because the host is Ubuntu and has no zypper installed at all — and that's expected. The host's only job is to run Docker and host the sandbox; the openSUSE work happens inside it.

---

## Refreshing Repository Metadata

Just like `apt update` or dnf's automatic metadata refresh, zypper keeps a local cache of what each configured repository currently offers. That cache goes stale the moment a repository maintainer publishes something new, so the first move in any real maintenance session is to refresh it:

```bash
zypper refresh
```

```text
Repository 'Update repository with updates from SUSE Linux Enterprise 15' is up to date.
Repository 'Main Update Repository' is up to date.
All repositories have been refreshed.
```

This command changes nothing about what's installed on the system. It only updates zypper's own knowledge of what's currently available — package versions and, specifically on SUSE systems, patch definitions too. Skipping this step doesn't break anything immediately, but it does mean every question you ask afterward is answered against outdated information.

---

## Two Different Questions: Updates vs. Patches

Once the metadata is fresh, you can ask two genuinely different questions about what's upgradable.

```bash
zypper list-updates
```

This is the raw, package-by-package comparison: for every installed package, is there a newer version available in a configured repository? No curation, no categorization — just version arithmetic.

```bash
zypper list-patches
```

This instead lists SUSE's curated **patch objects** — named, tracked bundles that a repository maintainer explicitly assembled and published, each classified by category (security, recommended, optional/feature) and severity. A single patch can bundle several packages' updates together as one trackable unit, addressing a specific CVE or bug.

Here is the part that trips people up coming from Debian or Fedora: **these two lists do not have to match.** A package can show up in `zypper list-updates` with a newer version sitting right there in the repository, and simply have no patch covering it yet — in which case `zypper list-patches` won't mention it at all. That's not a bug. It's the whole point of the system: patches are a deliberate, reviewed layer on top of the raw version stream, not just a different display format for the same data.

---

## Applying the Right One: `zypper patch` vs `zypper update`

Once you know what's out there, you choose how to act on it — and this is where policy meets command syntax.

```bash
zypper patch
```

This applies **only** the updates covered by a currently published patch definition. Anything security-classified lives here. This is the conservative choice: "stay current on what's been reviewed and flagged, don't chase every version bump."

```bash
zypper update
```

This applies **every** available update, patch-covered or not. It's the "stay maximally current" posture — appropriate for some environments, but a real policy violation if the task actually called for a patch-only maintenance window.

If a policy is narrower still — "security patches only, nothing else" — zypper lets you filter by category:

```bash
zypper patch --category security
```

A scenario that says "conservative," "security-focused," or "don't chase every package bump" is describing `zypper patch`, not `zypper update`. Running the wrong one doesn't just use the wrong syntax — it changes what actually lands on the system.

---

## Installing and Removing Packages

Ordinary package installation and removal work the way you'd expect from any RPM-family tool, with familiar shorthand aliases:

```bash
zypper install fail2ban
# shorthand: zypper in fail2ban
```

```bash
zypper remove telnet-server
# shorthand: zypper rm telnet-server
```

Because openSUSE is RPM-based underneath zypper, package removal follows RPM's own config-file handling automatically: an unmodified configuration file that shipped with the package gets deleted along with the rest of it, while a file you've locally edited gets preserved with an `.rpmsave`-style suffix rather than silently destroyed. There is no separate `zypper purge` command mirroring APT's remove/purge split — the decision is made per-file, automatically, by RPM's own modification check.

---

## Reading Zypper's Own History

Every operation zypper performs — installs, removals, patches applied — gets written to an ordered, timestamped log:

```bash
zypper history
```

```text
2026-02-14 09:12:03|patch |install|patch:openSUSE-2026-142|1|noarch||
2026-02-14 09:14:41|install|install|fail2ban|1.0.2-1.5|noarch|repo-oss|
2026-02-14 09:15:09|remove |remove |telnet-server|1.2-1.30|noarch||
```

That log is a genuine audit trail — it tells you exactly what happened and in what order, which matters enormously when you're reconstructing a maintenance window after the fact. But be precise about what it is *not*: unlike `dnf history undo <id>`, there is no `zypper history undo`. Zypper's history is a record, not a transaction ledger you can mechanically reverse. If you need to undo something you find in that log, you do it manually — reinstall what was removed, remove what was newly installed, or install a specific older version explicitly if it's still available — informed by what the log tells you happened, not by a single rollback command.

---

## Self-Check and Verification

To prove your zypper fundamentals are solid before moving on:

1. Inside the `zypperbox` container, run `zypper refresh` and confirm it completes without modifying anything installed.
2. Run `zypper list-updates` and `zypper list-patches` side by side and identify at least one package that appears differently between the two (or confirm there's nothing to compare on a fully current system).
3. Apply `zypper patch` and observe which updates actually land versus what `zypper list-updates` still shows afterward.
4. Install a package with `zypper install`, remove a different one with `zypper remove`, and confirm each change with `rpm -q`.
5. Run `zypper history` and read the tail of the log — confirm you can narrate exactly what happened during your session and in what order, purely from that log.
