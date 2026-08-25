# Section 070 Knowledge Check: SUSE Package Management: Zypper

Test your understanding of zypper's patch-versus-update distinction, its research subcommands, its history log, and the Docker-based openSUSE sandbox this section runs inside.

---

## Scenario-Based Questions

### Question 1
You SSH into the lab VM and type `zypper refresh` directly at the shell prompt, expecting to see the openSUSE repositories sync. Instead you get `zypper: command not found`. What is the cause, and what should you do instead?
*   **A)** The VM's `zypper` binary is corrupted and needs to be reinstalled with `apt`.
*   **B)** The VM itself is Ubuntu 24.04, not openSUSE — `zypper` only exists inside the `zypperbox` container. You need to run `docker exec -it zypperbox bash` first, then run zypper commands inside that shell.
*   **C)** `zypper` requires a reboot of the VM before it becomes available on the PATH.
*   **D)** `zypper` must be prefixed with `sudo` for the shell to recognize it as a valid command.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** This lab's VM boots from the platform's only available base image, Ubuntu 24.04, which has no zypper or openSUSE package database at all. To provide a genuine openSUSE experience anyway, bootstrap installs Docker and starts a long-lived `opensuse/leap:15.6` container named `zypperbox`. All zypper work happens inside that container, reached via `docker exec -it zypperbox bash` — not on the Ubuntu host directly.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because there is no zypper binary to corrupt on an Ubuntu host — it was never installed there in the first place, by design.
    *   *Option C* is incorrect because no reboot would install a package manager that doesn't exist for this distribution on this host.
    *   *Option D* is incorrect because `sudo` changes privilege level, not command lookup — a genuinely missing binary returns "command not found" regardless of `sudo`.
</details>

---

### Question 2
Your team's policy for this openSUSE host is strictly conservative: apply security-tracked fixes promptly, but do not chase every routine package version bump during the maintenance window. Which single command matches that policy?
*   **A)** `zypper update`
*   **B)** `zypper dup`
*   **C)** `zypper patch`
*   **D)** `zypper install --force`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: C**

*   **Why C is correct:** `zypper patch` applies only the updates covered by currently published, curated patch definitions — the layer where SUSE tracks security and bug-fix bundles deliberately. It leaves any raw package version bump not covered by a published patch untouched, which is precisely the "security patches promptly, don't chase every bump" posture.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because `zypper update` applies every available update regardless of patch coverage — a more aggressive outcome than the stated conservative policy calls for.
    *   *Option B* is incorrect because `zypper dup` performs a full distribution version upgrade/sync, an even larger and riskier operation than a routine update, nowhere near what a conservative policy would call for.
    *   *Option D* is incorrect because `install --force` reinstalls or forces a specific package installation; it has nothing to do with applying updates or patches across the system.
</details>

---

### Question 3
While auditing an openSUSE host, you run both `zypper list-updates` and `zypper list-patches` right after a fresh `zypper refresh`. The two commands return different sets of package names. A colleague says this must mean one of the commands is broken. Are they right?
*   **A)** Yes — after a refresh, both commands should always report identical results, so a mismatch indicates a stale cache.
*   **B)** No — `list-updates` reports every installed package with a newer version available (a raw version comparison), while `list-patches` reports only the curated, tracked patch bundles a maintainer has explicitly published; a package can have a newer version with no patch covering it yet, so the two lists legitimately differ.
*   **C)** Yes — `list-patches` is deprecated in openSUSE Leap 15.6 and should never return results.
*   **D)** No — but only because `list-updates` ignores security-classified packages entirely.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** These two commands answer genuinely different questions. `list-updates` is a straightforward package-by-package version comparison with no curation involved. `list-patches` lists SUSE's tracked patch objects — named bundles a repository maintainer explicitly assembled and classified by category and severity. A package appearing in one list without appearing in the other is expected behavior, not a malfunction.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because a fresh refresh does not force these two structurally different reports to converge — they answer different questions by design.
    *   *Option C* is incorrect because `list-patches` is a fully supported, current subcommand on openSUSE Leap 15.6.
    *   *Option D* is incorrect because `list-updates` doesn't filter by security classification at all — it has no concept of patch categories; that classification only exists on the patch side.
</details>

---

### Question 4
You mistakenly ran `zypper remove` on a package that turned out to still be needed. You want to reverse the mistake and ask a colleague whether `zypper history` can undo it for you the way `dnf history undo <id>` would on a Red Hat–family system. What is the accurate answer?
*   **A)** Yes — `zypper history undo <id>` mechanically reverses any past zypper transaction, identically to dnf.
*   **B)** No — `zypper history` is an ordered, timestamped audit log of what zypper has done; it has no undo/rollback subcommand, so reversing the removal means manually reinstalling the package, informed by what the log shows happened.
*   **C)** Yes, but only for `patch` operations, not for `install` or `remove` operations.
*   **D)** No — `zypper history` cannot be read at all once a new operation has been performed.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `zypper history` is a genuine audit trail — it records what was installed, removed, or patched, and when, in order. It is not a transactional rollback mechanism. There is no `zypper history undo` equivalent to `dnf history undo`. Reversing a mistaken removal means manually reinstalling the specific package, using the log only to confirm exactly what happened and when.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because no such `undo` subcommand exists under `zypper history` at all — this is a real, documented difference from dnf, not a missing flag.
    *   *Option C* is incorrect because there's no partial undo capability scoped to just patch operations either — the log format doesn't support mechanical reversal for any operation type.
    *   *Option D* is incorrect because `zypper history` remains fully readable and continues accumulating entries indefinitely; new operations don't erase or block access to prior ones.
</details>

---

### Question 5
A colleague reports that a script on your openSUSE host fails because the `ip` command can't be found at `/usr/sbin/ip`. You need to determine which package would need to be installed to provide that exact file — without installing anything yet, since you first want to confirm the correct package name. Which command answers this?
*   **A)** `rpm -qf /usr/sbin/ip`
*   **B)** `zypper search --installed-only ip`
*   **C)** `zypper what-provides /usr/sbin/ip`
*   **D)** `zypper info ip`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: C**

*   **Why C is correct:** `zypper what-provides` searches configured repositories' published metadata for any package that declares it would place a file at that exact path, regardless of whether it's currently installed. This is exactly what's needed here, since the file isn't on the system yet — the question is which package *would* provide it.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because `rpm -qf` only queries the local RPM database for files that are already installed on the system; since `/usr/sbin/ip` doesn't exist locally yet, it would report the file isn't owned by any installed package, answering nothing useful here.
    *   *Option B* is incorrect because `search --installed-only` filters to packages already present on the system, which is the opposite of what's needed when researching an uninstalled dependency.
    *   *Option D* is incorrect because `zypper info` requires the exact package name as its argument — but the package name (likely `iproute2`) is precisely what's unknown here; `info` does not resolve file paths to package names.
</details>
