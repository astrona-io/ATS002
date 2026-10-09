# Section 060 Knowledge Check: RPM/DNF Package Management

Astronaut, test what you know about single-package work with `rpm`, RPM database repair, the daily `dnf` loop, read-only package research and `dnf` package groups. Pick an answer for each question before you open the explanation.

---

## Scenario-Based Questions

Each question describes a real situation on a training ship. Pick one answer, then open the answer box to check your reasoning.

### Question 1
A colleague hands you `/home/candidate/downloads/acme-tool-3.2.0-1.x86_64.rpm`. It is an internal tool that no repository publishes. Before you install anything, you want to see exactly which files it would place on disk. Which command should you run, and why?
*   **A)** `rpm -ql acme-tool-3.2.0-1.x86_64.rpm` — lists the files of an already-installed package by name.
*   **B)** `rpm -qlp acme-tool-3.2.0-1.x86_64.rpm` — the `-p` modifier tells `rpm` to read the archive file on disk directly, rather than looking for an already-installed package of the same name.
*   **C)** `rpm -qa | grep acme-tool` — lists every installed package on the system and filters the output.
*   **D)** `dnf provides acme-tool-3.2.0-1.x86_64.rpm` — queries repository metadata for anything that would provide a file matching that literal filename.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `rpm` treats a file path and an installed package name as two different kinds of argument. The `-p` modifier tells `rpm -ql` to read the `.rpm` file directly from disk and report the files it *would* place. Nothing has to be installed first. This is exactly the "look before you leap" step: read the crate's label before you open it.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because without `-p`, `rpm -ql` searches the *installed* package database for a package literally named `acme-tool-3.2.0-1.x86_64.rpm`. No such package exists, because nothing has been installed yet.
    *   *Option C* is incorrect because `rpm -qa` only reports what is already installed. A new `.rpm` file that was never installed does not appear in it at all.
    *   *Option D* is incorrect because `dnf provides` answers "which package provides this file or capability?", not "which files does this archive contain?". It also searches repository metadata, not a local file.
</details>

---

### Question 2
On a Rocky Linux 9 host, `rpm -qa` fails with output like `error: rpmdb: BDB0113 Thread/process ... : unable to lock ...` mixed in with otherwise normal package listings. What is the correct diagnosis, and what should you do about it?
*   **A)** This is a dependency conflict; the fix is `sudo dnf distro-sync` to reconcile mismatched package versions.
*   **B)** This is genuine RPM database corruption; confirm the actual backend with `ls -la /var/lib/rpm`, back up `/var/lib/rpm` before touching anything, then run `sudo rpm --rebuilddb`.
*   **C)** This is a disk-space problem; the fix is to expand the underlying disk immediately, with no further diagnosis needed.
*   **D)** This is expected, harmless output whenever EPEL is enabled, and requires no action.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** The error text complains about the database layer itself (`rpmdb`). It does not name a missing or conflicting package, and it does not say "no space left". That is the fingerprint of database corruption. (`BDB` is the prefix of Berkeley DB's own messages. Rocky Linux 9 normally uses a `sqlite`-based database instead, which is exactly why you check the real backend before following advice written for one or the other.) Backing up before `--rebuilddb` costs seconds and is your only way back if the repair does not go as expected.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because a real dependency conflict clearly names a missing or conflicting package. This error is about the database's internal consistency, not any package's dependencies.
    *   *Option C* is incorrect because a disk-space problem is confirmed or ruled out with `df -h /var`, and `rpm` and `dnf` usually say "no space left" outright. Expanding a disk without confirming the cause skips the diagnosis entirely.
    *   *Option D* is incorrect because this error text is never expected or harmless. EPEL being enabled has nothing to do with local RPM database locking or consistency errors.
</details>

---

### Question 3
You accidentally installed `fail2ban` and `mtr` together in a single `dnf install` command, so a package nobody asked for came along. You want to remove the *entire* transaction as one unit, not just uninstall the unwanted package by hand. What is the correct approach?
*   **A)** Run `sudo dnf remove mtr` — removes just the unwanted package, leaving `fail2ban` and the original transaction record in place.
*   **B)** Identify the transaction with `dnf history list` / `dnf history info <id>`, then run `sudo dnf history undo <id>` to undo the whole transaction as a single, atomic unit.
*   **C)** Run `sudo dnf autoremove` — this only cleans up orphaned dependency packages that nothing else needs, not a mixed transaction you explicitly requested.
*   **D)** Run `sudo dnf reinstall fail2ban mtr` — reinstalls both packages fresh, without undoing anything.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `dnf` keeps a real transaction history, something Debian's `apt` has no direct match for. `dnf history undo <id>` reverses a whole past transaction as one unit. It undoes exactly what that transaction did (installing both `fail2ban` and `mtr`), so you do not have to work out and reverse each change by hand.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because it only deals with `mtr`. The original transaction still mixed in an unwanted package, and you get no clean way to redo just the intended part afterwards.
    *   *Option C* is incorrect because `autoremove` only targets leftover dependencies nothing else needs. `mtr` was requested by name in the transaction, not pulled in as a dependency, so `autoremove` does not touch it.
    *   *Option D* is incorrect because reinstalling both packages undoes nothing. It leaves `mtr` installed, the opposite of the goal.
</details>

---

### Question 4
A colleague reports that a script fails because the `ip` command is not found on a fresh Rocky Linux 9 host. You want to find which package would need to be installed to provide it, without installing anything yet and without guessing the package name from memory. Which command actually answers this?
*   **A)** `rpm -qf /usr/sbin/ip` — searches the local RPM database for whatever already-installed package owns that path.
*   **B)** `dnf provides '*/ip'` — searches every configured repository's metadata for any package that declares it would place a file matching that name, regardless of current install state.
*   **C)** `dnf list installed | grep ip` — lists currently installed packages matching a naming pattern.
*   **D)** `dnf search ip` — matches package names and summary text against the keyword `ip`, which is a very broad, imprecise match for a specific command name.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `dnf provides` (also spelled `whatprovides`) answers a question `rpm -qf` cannot: "which package would I need to install to get this?". It searches repository metadata, which exists whether or not anything is installed. The `*/ip` glob matches the command in any directory, which is more robust than guessing an exact path.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because `rpm -qf` only searches the *local, installed* database. `ip` is not installed and the file does not exist locally, so this cannot answer "what would provide it?".
    *   *Option C* is incorrect because `ip` is not installed in this scenario, so it can never appear in `dnf list installed`, whatever the grep pattern.
    *   *Option D* is incorrect because `dnf search` matches loosely against names and summary text. A bare keyword search for `ip` returns a flood of unrelated results instead of the one package that provides that exact command.
</details>

---

### Question 5
On a host, `automake` was already installed on its own, for an unrelated reason, before anyone touched the `"Development Tools"` group. Later, someone runs `sudo dnf group install "Development Tools"` (`automake` is also a member of that group), and afterwards runs `sudo dnf group remove "Development Tools"`. Does that group removal remove `automake`?
*   **A)** Yes — `automake` is a member of the group's metadata, and `dnf group remove` removes every package the group lists as a member.
*   **B)** No — `dnf` only removes packages it tracked as having been installed *specifically as part of* that group transaction; `automake` predates the group install, so its removal was never tracked as belonging to it, and it survives.
*   **C)** Yes — because `--with-optional` was never passed during the install, `dnf` falls back to removing every package the group could possibly include.
*   **D)** No — because `automake` is classified as a "mandatory" tier member, and mandatory-tier packages are permanently protected from any future removal.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `dnf group remove` works from `dnf`'s own records, not from the group's member list. It removes what it recorded as installed *because of* that group transaction. A package that was already installed on its own is not swept up just because the group also lists it. What `dnf` recorded decides the removal, not the overlap between "what is installed" and "what the group lists".
*   **Why others are incorrect:**
    *   *Option A* is incorrect because it describes removal by membership, which is exactly the common wrong assumption that `dnf`'s record-based behaviour avoids.
    *   *Option C* is incorrect because `--with-optional` only controls whether Optional members are pulled in *at install time*. It has no effect on which packages a later group removal targets.
    *   *Option D* is incorrect because Mandatory, Default and Optional are install-time tiers. They say whether a package installs with the group, not whether it is protected from removal, and no such protection exists.
</details>
