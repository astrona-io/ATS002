# Section 060: RPM/DNF Package Management: rpm, dnf & Package Groups

Welcome to the RHEL-family half of your package-management training. Every production Rocky Linux, RHEL, or Fedora-family server you will ever touch lives and dies by `rpm` and `dnf` the same way a Debian-family server lives and dies by `dpkg` and `apt` — the thing that decides what software is present, which exact version is running, and whether a routine maintenance window quietly breaks something or keeps the system exactly as predictable as it was yesterday.

In this section, you move through the full RPM-family package-management stack from the bottom up. You will start at `rpm`, the low-level tool that actually unpacks and registers software on disk, then climb to `dnf`, the dependency-aware, repository-fetching layer almost everyone uses day to day, and finish at `dnf`'s package groups — a first-class, repository-published feature for installing and removing a whole curated toolchain as a single unit, something APT has no real native equivalent for.

**A note on how these labs actually run.** This repository's practice VMs only come in one flavor: an Ubuntu 24.04 image. There is no Rocky Linux or RHEL virtual machine available on this platform, and `rpm`/`dnf` aren't Ubuntu tools — Ubuntu uses `dpkg`/`apt` instead. Rather than fake `rpm`/`dnf` output or ask you to trust command transcripts you can't actually run, every lab in this section has its bootstrap install Docker on the Ubuntu VM and start a long-lived, privileged Rocky Linux 9 container named `rpmbox`, left running for your whole session. Everything inside it is the real thing — a real Rocky Linux 9 userspace, a real `rpm` binary, a real `dnf`, a real RPM database. Nothing is simulated; the only unusual part is that you reach it through `docker exec -it rpmbox bash` instead of SSH-ing directly into a Rocky VM. Every module below explains this the first time it comes up and then simply gets on with the real work.

---

## What You Will Master

By completing this section, you will acquire five core administrative capabilities:
*   **Low-Level RPM Package Surgery:** How to inspect, install, and interrogate a standalone `.rpm` file with `rpm`, answer file-ownership questions in both directions, and verify an installed package's integrity against what was recorded at install time.
*   **RPM Database Recovery:** How to recognize genuine RPM database corruption on a real, sqlite-backed `rpmdb` (as opposed to a dependency conflict or a disk-space problem), back it up safely, and rebuild it to a clean, queryable state.
*   **The Daily DNF Maintenance Loop:** How to correctly sequence `dnf check-update`, `dnf upgrade`, `dnf install`, and `dnf remove`/`autoremove`, and how to use `dnf history` to undo — and redo — an entire past transaction as a single unit.
*   **Package Research Before Action:** How to search by keyword, pull full metadata, and find what package would provide a missing file or command — entirely read-only, before any install ever happens.
*   **Package Groups as a First-Class Unit:** How to discover, inspect, install, and cleanly remove a genuine repository-published `dnf` group (with real mandatory/default/optional membership tiers), and reason precisely about what a group removal does and doesn't touch.

---

## The Learning & Lab Path

This section is divided into five highly focused, sequential modules. Each module is paired with a dedicated hands-on virtual sandbox practice lab, and concluded with a comprehensive Capstone Integration Challenge:

### 1. RPM Low-Level Package Management
*   **Module Reader:** **[Module 1: RPM Low-Level Package Management](./module-01/course.md)**
    1. [What rpm knows, and inspecting a .rpm](./module-01/course-01-rpm-scope-and-inspecting.md)
    2. [Installing directly, and ownership queries](./module-01/course-02-installing-and-ownership.md)
    3. [Verifying integrity](./module-01/course-03-verifying-integrity.md)
*   **Practice Lab Sandbox:** **`sections/section-060/module-01/labs/lab-01`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-060/module-01/labs/lab-01
    ```
*   **Hands-on Objective:** Inspect a standalone `.rpm` file before installing it, install it directly with `rpm`, answer file-ownership questions in both directions, and verify that its installed files still match what the package originally recorded.

### 2. Rebuilding a Corrupted RPM Database
*   **Module Reader:** **[Module 2: Rebuilding a Corrupted RPM Database](./module-02/course.md)**
    1. [Recognising the symptom, and not assuming the backend](./module-02/course-01-recognising-the-symptom.md)
    2. [Back up, rebuild, verify](./module-02/course-02-backup-rebuild-verify.md)
*   **Practice Lab Sandboxes:**
    1. **`sections/section-060/module-02/labs/lab-01`** — genuine sqlite rpmdb corruption: back up and `rpm --rebuilddb`
    2. **`sections/section-060/module-02/labs/lab-02`** — a corruption *look-alike*: `dnf check` fails, but it is an unmet dependency, not the database — do **not** rebuild
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-060/module-02/labs/lab-01
    ```
*   **Hands-on Objective:** Confirm a genuinely corrupted, real sqlite-backed RPM database (not a dependency conflict or a disk-space problem), back it up, rebuild it, and verify the system is back to a clean, queryable state.

### 3. DNF Basic Package Operations
*   **Module Reader:** **[Module 3: DNF Basic Package Operations](./module-03/course.md)**
    1. [The everyday dnf loop](./module-03/course-01-the-dnf-loop.md)
    2. [Removing, and transactional history](./module-03/course-02-removing-and-history.md)
*   **Practice Lab Sandbox:** **`sections/section-060/module-03/labs/lab-01`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-060/module-03/labs/lab-01
    ```
*   **Hands-on Objective:** Run a realistic `dnf` maintenance pass — check and apply upgrades, install and remove packages, clean up orphaned dependencies, and use `dnf history` to undo and redo a transaction.

### 4. DNF Package Information Lookup
*   **Module Reader:** **[Module 4: DNF Package Information Lookup](./module-04/course.md)**
    1. [Finding a package, and describing it](./module-04/course-01-search-and-describe.md)
    2. [What would provide this, and cross-referencing rpm](./module-04/course-02-provides-and-cross-referencing.md)
*   **Practice Lab Sandbox:** **`sections/section-060/module-04/labs/lab-01`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-060/module-04/labs/lab-01
    ```
*   **Hands-on Objective:** Research packages entirely read-only — find a candidate package by keyword, pull full metadata without installing it, determine what package would provide a missing command, and list installed packages by naming pattern.

### 5. DNF Package Groups
*   **Module Reader:** **[Module 5: DNF Package Groups](./module-05/course.md)**
    1. [What a group is, and discovering what exists](./module-05/course-01-what-a-group-is-and-discovering.md)
    2. [Inspecting membership, and installing](./module-05/course-02-inspecting-and-installing.md)
    3. [Confirming what landed, and removing cleanly](./module-05/course-03-confirming-and-removing.md)
*   **Practice Lab Sandbox:** **`sections/section-060/module-05/labs/lab-01`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-060/module-05/labs/lab-01
    ```
*   **Hands-on Objective:** Discover a repository-published package group, inspect its real mandatory/default/optional membership before installing it, install and confirm it, then remove it cleanly — while reasoning precisely about which packages the removal does and doesn't touch.

### 6. Section Capstone Challenge
*   **Comprehensive Challenge:** **`sections/section-060/capstone/labs/lab-01` (RPM/DNF Package Management Capstone)**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-060/capstone/labs/lab-01
    ```
*   **Hands-on Objective:** Connect the dots on an overnight incident — diagnose and repair a genuinely corrupted RPM database, inspect and install a standalone RPM staged before the incident, then discover, inspect, and install a full `dnf` package group to finish setting the host up as a build server.

---

## Ready for Assessment?

Test your theoretical knowledge and diagnostic reasoning before tackling the practical lab missions:

*   **[Take the Section 060 Knowledge Check Quiz](./quiz.md)**
