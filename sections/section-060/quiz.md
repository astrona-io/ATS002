# Section 060 Knowledge Check: RPM/DNF Package Management

Test your understanding of low-level `rpm` package surgery, RPM database recovery, the daily `dnf` maintenance loop, read-only package research, and `dnf` package groups.

---

## Scenario-Based Questions

### Question 1
A colleague hands you `/home/candidate/downloads/acme-tool-3.2.0-1.x86_64.rpm` — an internal tool, not published to any repository. Before installing anything, you want to see exactly which files it would place on disk. Which command should you run, and why?
*   **A)** `rpm -ql acme-tool-3.2.0-1.x86_64.rpm` — lists the files of an already-installed package by name.
*   **B)** `rpm -qlp acme-tool-3.2.0-1.x86_64.rpm` — the `-p` modifier tells `rpm` to read the archive file on disk directly, rather than looking for an already-installed package of the same name.
*   **C)** `rpm -qa | grep acme-tool` — lists every installed package on the system and filters the output.
*   **D)** `dnf provides acme-tool-3.2.0-1.x86_64.rpm` — queries repository metadata for anything that would provide a file matching that literal filename.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `rpm` structurally distinguishes between a file-path argument and an installed-package-name argument. The `-p` modifier is what tells `rpm -ql` to read the `.rpm` archive directly from disk and report the files it *would* place, without requiring anything to already be installed. This is exactly the "look before you leap" step from Chapter 1.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because dropping `-p` makes `rpm -ql` search the *installed*-package database for a package literally named `acme-tool-3.2.0-1.x86_64.rpm` — which doesn't exist, since nothing has been installed yet.
    *   *Option C* is incorrect because `rpm -qa` only ever reports what's already installed; a brand-new standalone `.rpm` file that has never been installed won't appear in it at all.
    *   *Option D* is incorrect because `dnf provides` answers "what package provides this file/capability," not "what files does this specific archive contain" — and it searches repository metadata, not a literal local file path.
</details>

---

### Question 2
On a Rocky Linux 9 host, `rpm -qa` fails with output like `error: rpmdb: BDB0113 Thread/process ... : unable to lock ...` mixed in with otherwise normal package listings. What's the correct diagnosis, and what should you do about it?
*   **A)** This is a dependency conflict; the fix is `sudo dnf distro-sync` to reconcile mismatched package versions.
*   **B)** This is genuine RPM database corruption; confirm the actual backend with `ls -la /var/lib/rpm`, back up `/var/lib/rpm` before touching anything, then run `sudo rpm --rebuilddb`.
*   **C)** This is a disk-space problem; the fix is to expand the underlying disk immediately, with no further diagnosis needed.
*   **D)** This is expected, harmless output whenever EPEL is enabled, and requires no action.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** The error text specifically complains about the database layer itself (`rpmdb`), not a named missing or conflicting package and not an explicit "no space left" message — that's the fingerprint of database corruption, not a dependency or disk-space problem. Rocky Linux 9 uses a `sqlite`-backed `rpmdb`, not the older Berkeley DB layout, so confirming the actual backend before following generic advice matters. Backing up before `--rebuilddb` costs seconds and is the only rollback path if the repair doesn't go as expected.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because a real dependency conflict names a specific missing or conflicting package clearly; this error is about the database's internal consistency, not any package's dependencies.
    *   *Option C* is incorrect because a genuine disk-space problem is confirmed or ruled out with `df -h /var` and `rpm`/`dnf` themselves usually say "no space left" outright — jumping straight to expanding a disk without confirming that's the actual cause skips the diagnosis entirely.
    *   *Option D* is incorrect because this error text is never expected or harmless; EPEL being enabled has nothing to do with local RPM database locking/consistency errors.
</details>

---

### Question 3
You accidentally installed `fail2ban` and `mtr` together in a single `dnf install` command, bundling in a package nobody actually asked for. You want to remove the *entire* transaction as one unit, not just manually uninstall the unwanted package. What's the correct approach?
*   **A)** Run `sudo dnf remove mtr` — removes just the unwanted package, leaving `fail2ban` and the original transaction record in place.
*   **B)** Identify the transaction with `dnf history list` / `dnf history info <id>`, then run `sudo dnf history undo <id>` to undo the whole transaction as a single, atomic unit.
*   **C)** Run `sudo dnf autoremove` — this only cleans up orphaned dependency packages that nothing else needs, not a mixed transaction you explicitly requested.
*   **D)** Run `sudo dnf reinstall fail2ban mtr` — reinstalls both packages fresh, without undoing anything.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `dnf`'s genuinely transactional history is a real capability APT has no direct equivalent for — `dnf history undo <id>` reverses an entire past transaction as a coherent unit, exactly reversing whatever that transaction did (installing both `fail2ban` and `mtr` together), rather than requiring you to manually figure out and undo each individual side effect.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because it only addresses `mtr`; it doesn't touch the fact that the original transaction still mixed an unwanted package in, and doesn't give you a clean way to redo just the intended part afterward.
    *   *Option C* is incorrect because `autoremove` only targets orphaned dependencies nothing else needs — `mtr` was explicitly requested in the transaction, not pulled in as an unrequested dependency, so `autoremove` won't touch it.
    *   *Option D* is incorrect because reinstalling both packages doesn't undo anything — it would leave `mtr` installed, the opposite of the goal.
</details>

---

### Question 4
A colleague reports a script fails because the `ip` command isn't found on a fresh Rocky Linux 9 host. You want to determine which package would need to be installed to provide it — without installing anything yet, and without guessing the package name from memory. Which command actually answers this?
*   **A)** `rpm -qf /usr/sbin/ip` — searches the local RPM database for whatever already-installed package owns that path.
*   **B)** `dnf provides '*/ip'` — searches every configured repository's metadata for any package that declares it would place a file matching that name, regardless of current install state.
*   **C)** `dnf list installed | grep ip` — lists currently installed packages matching a naming pattern.
*   **D)** `dnf search ip` — matches package names and summary text against the keyword `ip`, which is a very broad, imprecise match for a specific command name.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `dnf provides` (aliased `whatprovides`) answers a question `rpm -qf` structurally cannot: "what package would I need to install to get this," searching repository metadata that exists independently of anything currently installed. The `*/ip` glob matches the command regardless of which directory it ends up in, which is more robust than guessing an exact path.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because `rpm -qf` only ever searches the *local, installed* database — since `ip` isn't installed, and the command doesn't even exist locally to query in the first place, this cannot answer "what would provide it."
    *   *Option C* is incorrect because `ip` isn't installed at all in this scenario, so it can never appear in `dnf list installed`, regardless of the grep pattern.
    *   *Option D* is incorrect because `dnf search` matches loosely against names and summary text — a bare keyword search for `ip` would return a flood of unrelated, tangentially-matching results rather than precisely identifying the package that provides that exact command.
</details>

---

### Question 5
On a host, `automake` was already installed independently, for an unrelated reason, before anyone ever touched the `"Development Tools"` group. Later, someone runs `sudo dnf group install "Development Tools"` (of which `automake` is also a member), and afterward runs `sudo dnf group remove "Development Tools"`. Is `automake` removed by that group removal?
*   **A)** Yes — `automake` is a member of the group's metadata, and `dnf group remove` removes every package the group lists as a member.
*   **B)** No — `dnf` only removes packages it tracked as having been installed *specifically as part of* that group transaction; `automake` predates the group install, so its removal was never tracked as belonging to it, and it survives.
*   **C)** Yes — because `--with-optional` was never passed during the install, `dnf` falls back to removing every package the group could possibly include.
*   **D)** No — because `automake` is classified as a "mandatory" tier member, and mandatory-tier packages are permanently protected from any future removal.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `dnf group remove`'s semantics are tracking-based, not membership-based. It removes what it recorded as installed *because of* that specific group transaction. A package already present beforehand, installed independently for an unrelated reason, is not swept up just because it also happens to be listed in the group's metadata — `dnf`'s own provenance tracking is what governs removal, not raw overlap between "what's installed" and "what the group lists."
*   **Why others are incorrect:**
    *   *Option A* is incorrect because it describes membership-based removal, which is exactly the wrong (and common) assumption `dnf`'s actual tracking-based behavior avoids.
    *   *Option C* is incorrect because `--with-optional` only controls whether optional-tier members are pulled in *at install time* — it has no bearing on which packages a later group removal targets.
    *   *Option D* is incorrect because mandatory/default/optional are install-time tiers describing whether a package installs automatically with the group — they say nothing about permanent removal protection, and no such protection exists.
</details>
