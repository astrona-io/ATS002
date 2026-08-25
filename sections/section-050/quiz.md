# Section 050 Knowledge Check: Debian Package Management: Repositories, dpkg & APT

Test your understanding of third-party repository trust, low-level `dpkg` recovery, the daily APT maintenance loop, read-only package research, and bulk group operations.

---

## Scenario-Based Questions

### Question 1
You need to add a vendor's third-party APT repository for `nginx` the modern, non-deprecated way. You've already run `curl -fsSL https://vendor.example.com/nginx/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/vendor-nginx.gpg`. What is the correct next step, and why does it matter?
*   **A)** Run `sudo apt-key add /etc/apt/keyrings/vendor-nginx.gpg`, which registers the key in APT's global trusted keyring so every repository can use it.
*   **B)** Add a line to `/etc/apt/sources.list.d/vendor-nginx.list` reading `deb [signed-by=/etc/apt/keyrings/vendor-nginx.gpg] https://vendor.example.com/nginx/ubuntu jammy main`, scoping trust to only this repository line.
*   **C)** Copy the key directly into `/etc/apt/trusted.gpg.d/` and skip the `sources.list.d` entry entirely, since the key alone is sufficient.
*   **D)** Run `sudo apt update` immediately — no repository definition file is needed once the key exists.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** The `signed-by=` option inside the repository's own `.list` file is what ties the dedicated keyring to *only that repository line*. Without it, APT has no repository definition to fetch packages from at all, and even with the key dearmored correctly, nothing about this vendor's software is reachable yet.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because `apt-key add` is deprecated specifically because it places a key in one shared, global keyring trusted for *every* configured repository — the opposite of the scoped trust `signed-by=` provides.
    *   *Option C* is incorrect because a key with no repository definition referencing it verifies nothing; APT still needs a `deb` line telling it where to fetch packages and at what priority.
    *   *Option D* is incorrect because `apt update` only refreshes indexes for repositories APT already knows about — without a `.list` file, this vendor repository was never configured in the first place.
</details>

---

### Question 2
You inherit a system where `dpkg -l | grep acme-agent` shows `iF acme-agent 4.2.0 amd64`. What does the `iF` status mean, and what is the correct first recovery command?
*   **A)** The package failed to install entirely and must be reinstalled from scratch with `dpkg -i`.
*   **B)** The package is fully installed and functioning; `iF` simply denotes it was installed from a flat/file source rather than a repository.
*   **C)** The package is "Unpacked" but not yet configured; run `sudo apt --fix-broken install` first, since only `apt` has repository awareness.
*   **D)** The package is "half-configured" — files are on disk but its post-install configuration step never finished; run `sudo dpkg --configure -a` first, then `sudo apt --fix-broken install` as a safety net.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: D**

*   **Why D is correct:** In `dpkg -l`'s status column, the second letter reflects current status; `F` specifically means "half-conFigured" — the package's files are present, but its configuration step (running the postinst script) was interrupted before finishing. The standard, expected recovery sequence is `dpkg --configure -a` (resume configuration for every pending package) followed immediately by `apt --fix-broken install` as a safety net for any genuinely missing dependency `dpkg` alone can't resolve.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because `iF` is a mid-step state, not a failed-and-absent one — the package's files are already on disk; reinstalling from scratch is unnecessary and not the standard recovery pattern.
    *   *Option B* is incorrect because `F` denotes "half-configured," an interrupted state, not a note about install source.
    *   *Option C* is incorrect because `dpkg --configure -a` — not `apt --fix-broken install` — is the correct *first* step for resuming an interrupted configuration; `apt --fix-broken install` is the follow-up safety net for a missing-dependency scenario specifically, since `dpkg` alone has no repository access to fetch anything.
</details>

---

### Question 3
During a routine maintenance window, `apt upgrade` finishes and its output ends with "The following packages have been kept back: libfoo". What does this mean, and what should you do next?
*   **A)** `libfoo` has no available update; the message is informational only and requires no action.
*   **B)** Upgrading `libfoo` would require installing or removing some other package, which plain `apt upgrade` refuses to do on its own; run `sudo apt full-upgrade` after confirming the add/remove it implies is expected and safe.
*   **C)** `libfoo` is held via `apt-mark hold`; run `sudo apt-mark unhold libfoo` and re-run `apt upgrade`.
*   **D)** The package index is stale; re-run `sudo apt update` and then `apt upgrade` again.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** "Kept back" specifically means a package's upgrade would change the installed package set beyond a simple version bump — a new dependency needed, or an obsolete one to drop — and plain `apt upgrade` deliberately won't do that on its own to keep upgrades predictable. `apt full-upgrade` (equivalently `apt-get dist-upgrade`) is the command willing to make that add/remove to complete the upgrade, and should be run only after reviewing that the implied change is expected.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because "kept back" specifically means an update *is* available but was deliberately skipped — it is not the same as "no update exists."
    *   *Option C* is incorrect because "kept back" is a distinct mechanism from `apt-mark hold`; nothing in the scenario indicates a manual hold was ever applied, and `apt-mark showhold` would confirm whether one exists before assuming so.
    *   *Option D* is incorrect because a stale index would more likely show the package as not upgradable at all, or with an outdated candidate version — "kept back" is APT's deliberate refusal to add/remove packages under plain `upgrade`, not a caching problem.
</details>

---

### Question 4
A task asks you to fully retire the `ftp` package, "including any dependency packages nothing else needs, and its configuration, so a future reinstall starts clean." Which sequence satisfies this completely?
*   **A)** `sudo apt remove ftp`
*   **B)** `sudo apt purge ftp`
*   **C)** `sudo apt purge ftp` followed by `sudo apt autoremove`
*   **D)** `sudo apt remove ftp` followed by `sudo apt-mark hold ftp`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: C**

*   **Why C is correct:** The task has two distinct requirements: configuration files gone (which requires `purge`, not plain `remove`) and orphaned dependencies gone (which requires the separate, deliberate `autoremove` step — removing `ftp` itself never automatically cascades to dependencies it alone pulled in). Only the combination of both commands satisfies the full request.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because plain `remove` leaves `ftp`'s configuration files under `/etc` in place — exactly the leftover state the task says to avoid.
    *   *Option B* is incorrect because `purge` alone handles the configuration-file requirement but does nothing about orphaned dependency packages that only `ftp` needed.
    *   *Option D* is incorrect on two counts: plain `remove` still leaves configuration files behind, and holding an already-removed package is nonsensical — `apt-mark hold` only affects packages still installed.
</details>

---

### Question 5
A host has an installed PHP 8.1 module family (`php8.1-cli`, `php8.1-fpm`, `php8.1-mysql`, and others sharing the `php8.1-` prefix). You need to hold the *entire* family together ahead of a risky, unrelated upgrade elsewhere on the system. Which approach is correct, and why does holding only `php8.1-cli` and `php8.1-fpm` (leaving the rest unheld) create a real risk?
*   **A)** `sudo apt-mark hold php8.1-cli php8.1-fpm` is sufficient — holding the two most commonly used modules protects the family well enough.
*   **B)** `apt list --installed 2>/dev/null | grep -E '^php8\.1-' | cut -d/ -f1 | xargs sudo apt-mark hold`, then confirm with `apt-mark showhold` — a partial hold risks the unheld modules drifting to a different PHP minor version than the held ones, breaking ABI compatibility across the family.
*   **C)** `sudo apt-mark hold php8.1-*` — the shell glob is expanded automatically by `apt-mark`, holding every matching package in one call.
*   **D)** Holding is unnecessary here; `apt full-upgrade` never touches packages outside the one named in the task.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** Pattern-matching the installed list with an anchored, extended-regex `grep -E '^php8\.1-'`, extracting clean names with `cut -d/ -f1`, and piping the full set into a single `xargs sudo apt-mark hold` call holds every matching package together in one atomic action — then `apt-mark showhold` audits that the result actually matches what was intended, rather than trusting the pipeline blindly. A partial hold is genuinely risky: if the family is interdependent (built against the same PHP ABI), the unheld members can drift to a newer PHP release during a future upgrade while the held ones stay behind, producing a version-mismatched, potentially broken installation.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because it's exactly the partial-hold risk the question describes — protecting some members of an interdependent set while leaving others exposed can be worse than protecting none.
    *   *Option C* is incorrect because `apt-mark hold` does not perform its own glob expansion against installed packages; `php8.1-*` would either be expanded by the shell against literal filenames in the current directory (almost never matching real package names) or passed through literally and fail to match anything.
    *   *Option D* is incorrect because an unrelated `apt full-upgrade` can still touch any package with a newer available candidate, including every unheld member of the PHP family, regardless of which single package a task happens to name.
</details>
