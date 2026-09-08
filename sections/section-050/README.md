# Section 050: Debian Package Management: Repositories, dpkg & APT

Welcome to the package management domain of your LFCS journey. Every production Debian or Ubuntu server you will ever touch lives and dies by its package manager — the thing that decides what software is present, which exact version is running, where it came from, and whether a routine maintenance window quietly breaks something or keeps the system exactly as predictable as it was yesterday.

In this section, you move through the full Debian package-management stack from the bottom up. You will start at `dpkg`, the low-level tool that actually unpacks and registers software on disk, then climb to `apt`, the dependency-aware layer almost everyone uses day to day, and finally out to third-party vendor repositories — software that doesn't live in Ubuntu's own archive at all. Along the way you will practice the two skills that separate a careful administrator from a dangerous one: locking a package's version down so it can't drift out from under you, and researching a package thoroughly *before* you commit to touching it.

Every exercise in this section runs natively on the Ubuntu VM using real `apt`/`dpkg` tooling — no exotic infrastructure, no cloud APIs, just the package manager you will use on the exam and in production.

---

## What You Will Master

By completing this section, you will acquire five core administrative capabilities:
*   **Third-Party Repository Trust:** How to add a vendor's APT repository using the modern, non-deprecated `signed-by` keyring approach, install an exact pinned version from it, and hold that version so routine upgrades leave it alone.
*   **Low-Level Package Surgery:** How to inspect, install, and interrogate a standalone `.deb` file with `dpkg`, and how to recognize and recover a package stuck in a half-configured, inconsistent state.
*   **The Daily APT Maintenance Loop:** How to correctly sequence `apt update`, `apt upgrade`/`apt full-upgrade`, `apt install`, and the crucial `apt remove` versus `apt purge` distinction, finishing with `apt autoremove` cleanup.
*   **Package Research Before Action:** How to search by keyword, pull full metadata, and confirm a package's installed-versus-candidate version and originating repository — entirely read-only, before any install ever happens.
*   **Bulk & Group Operations:** How to install a toolchain as a single atomic transaction, find an entire package family by naming pattern, and hold that whole interdependent family together rather than just one member of it.

---

## The Learning & Lab Path

This section is divided into five highly focused, sequential modules. Each module is paired with a dedicated hands-on virtual sandbox practice lab, and concluded with a comprehensive Capstone Integration Challenge:

### 1. Third-Party Repositories & Package Pinning
*   **Module Reader:** **[Module 1: Third-Party Repositories & Package Pinning](./module-01/course.md)**
    1. [Scoped trust — keyrings and signed-by](./module-01/course-01-scoped-trust.md)
    2. [Adding the repository and confirming it registered](./module-01/course-02-adding-the-repository.md)
    3. [Installing an exact version, and locking it](./module-01/course-03-exact-version-and-hold.md)
*   **Practice Lab Sandbox:** **`labs/section-050/module-01/lab-01`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-050/module-01/lab-01
    ```
*   **Hands-on Objective:** Add a vendor's third-party APT repository using the modern `signed-by` keyring approach (no `apt-key`), install an exact pinned version of its `nginx` package, and hold it so a routine upgrade cannot move it.

### 2. dpkg Low-Level Package Management
*   **Module Reader:** **[Module 2: dpkg Low-Level Package Management](./module-02/course.md)**
    1. [What dpkg knows, and inspecting a .deb](./module-02/course-01-dpkg-scope-and-inspecting-a-deb.md)
    2. [Installing directly, and ownership queries](./module-02/course-02-installing-and-ownership-queries.md)
    3. [Status codes and recovering an interrupted package](./module-02/course-03-status-codes-and-recovery.md)
*   **Practice Lab Sandbox:** **`labs/section-050/module-02/lab-01`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-050/module-02/lab-01
    ```
*   **Hands-on Objective:** Inspect a standalone `.deb` file before installing it, install it directly with `dpkg -i`, answer file-ownership questions in both directions, and recover an unrelated package left stuck in a half-configured state.

### 3. APT Basic Package Operations
*   **Module Reader:** **[Module 3: APT Basic Package Operations](./module-03/course.md)**
    1. [apt update is not apt upgrade](./module-03/course-01-update-is-not-upgrade.md)
    2. [Applying upgrades, and installing](./module-03/course-02-applying-upgrades-and-installing.md)
    3. [Removing cleanly](./module-03/course-03-removing-cleanly.md)
*   **Practice Lab Sandbox:** **`labs/section-050/module-03/lab-01`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-050/module-03/lab-01
    ```
*   **Hands-on Objective:** Run a realistic maintenance pass — refresh the index, preview and apply upgrades, install a new package, then fully purge an unneeded one (including its configuration and orphaned dependencies).

### 4. APT Package Information Lookup
*   **Module Reader:** **[Module 4: APT Package Information Lookup](./module-04/course.md)**
    1. [Finding a package, and describing it](./module-04/course-01-finding-and-describing.md)
    2. [Installed vs. candidate, and which source wins](./module-04/course-02-installed-vs-candidate.md)
*   **Practice Lab Sandbox:** **`labs/section-050/module-04/lab-01`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-050/module-04/lab-01
    ```
*   **Hands-on Objective:** Research packages entirely read-only — search by keyword, pull full metadata, confirm installed-versus-candidate version and source repository, and list installed/upgradable packages by pattern.

### 5. APT Package Groups & Bulk Operations
*   **Module Reader:** **[Module 5: APT Package Groups & Bulk Operations](./module-05/course.md)**
    1. [One transaction, and finding a family by pattern](./module-05/course-01-one-transaction-and-finding-a-family.md)
    2. [Bulk actions across a matched set](./module-05/course-02-bulk-actions-across-a-set.md)
*   **Practice Lab Sandbox:** **`labs/section-050/module-05/lab-01`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-050/module-05/lab-01
    ```
*   **Hands-on Objective:** Install a build toolchain as one atomic transaction, find an entire installed package family by naming pattern, and hold that whole family together ahead of a risky upgrade.

### 6. Section Capstone Challenge
*   **Comprehensive Challenge:** **`labs/section-050/capstone/lab-01` (New App Server Onboarding)**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-050/capstone/lab-01
    ```
*   **Hands-on Objective:** Connect the dots on a freshly provisioned server — trust and pin a vendor repository, recover a package stuck mid-install, install a toolchain and bulk-hold a package family, and research a package to answer a specific onboarding question.

---

## Ready for Assessment?

Test your theoretical knowledge and diagnostic reasoning before tackling the practical lab missions:

*   **[Take the Section 050 Knowledge Check Quiz](./quiz.md)**
