# Section 070: SUSE Package Management: Zypper

Welcome to the SUSE side of package management. Everything you've learned so far in this domain — refresh, search, install, remove, dependency resolution — carries over conceptually. What's new here is `zypper`, the package tool used across openSUSE and SUSE Linux Enterprise, and one genuinely distinctive concept neither `apt` nor `dnf` models the same way: a curated, tracked **patch** system layered on top of ordinary package version bumps.

**A note on how this section runs.** The only virtual machine image available on this training platform is Ubuntu 24.04 — there is no openSUSE image to boot directly. Rather than fake a zypper experience with a wrapper script, every lab in this section takes a more honest approach: bootstrap installs Docker on the Ubuntu VM, then starts a long-lived container from the real `opensuse/leap:15.6` image, named `zypperbox`. You do all of your zypper work by shelling into that container with `docker exec -it zypperbox bash`. Inside it, `zypper` is the genuine openSUSE tool, backed by the genuine RPM database, talking to genuine openSUSE repositories — nothing about the package management itself is simulated. Only the disk it runs on is virtualized. Every module and lab in this section repeats this instruction prominently, so you'll never be left wondering where to type a command.

---

## What You Will Master

By completing this section, you will acquire three core zypper capabilities:
*   **Refresh, Patch, and Update Discipline:** How to refresh repository metadata, and — critically — how to tell the difference between a raw package update (`zypper list-updates` / `zypper update`) and a curated, often security-focused patch (`zypper list-patches` / `zypper patch`), and why an administrator would deliberately choose one over the other.
*   **Install, Remove, and Audit:** How to install and remove packages with `zypper install`/`zypper remove`, and how to read zypper's own operation log with `zypper history` — while understanding, precisely, that it is an audit trail, not a `dnf history undo`-style rollback mechanism.
*   **Package Research Before Action:** How to find a package by rough keyword (`zypper search`), pull full metadata for one exact package without installing it (`zypper info`), discover which package would provide a missing file or command (`zypper what-provides`), and filter search results down to only what's already installed (`zypper search --installed-only`).

---

## The Learning & Lab Path

This section is divided into two modules, each paired with hands-on practice inside the `zypperbox` openSUSE sandbox, followed by a capstone lab that ties both skill sets together.

### 1. Zypper Basic Package Operations
*   **Module Reader:** **[Module 1: Zypper Basic Package Operations](./module-01/course.md)**
    1. [Refresh, and the two questions — updates vs. patches](./module-01/course-01-refresh-updates-vs-patches.md)
    2. [Applying the right one — zypper patch vs zypper update](./module-01/course-02-applying-the-right-one.md)
    3. [Installing, removing, and reading history](./module-01/course-03-install-remove-history.md)
*   **Associated Lab:** **`sections/section-070/module-01/labs/lab-01`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-070/module-01/labs/lab-01
    ```
*   **Hands-on Objective:** Inside `zypperbox`, refresh repository metadata, report available raw updates versus curated patches separately, apply only the patches per a conservative security policy, install `fail2ban`, remove `telnet-server` (the package providing the `telnetd` daemon), and review the resulting operation history.

### 2. Zypper Package Information Lookup
*   **Module Reader:** **[Module 2: Zypper Package Information Lookup](./module-02/course.md)**
    1. [The three research questions — search, info, what-provides](./module-02/course-01-the-three-questions.md)
    2. [Installed-only filtering, and the rpm fallback](./module-02/course-02-installed-only-and-rpm-fallback.md)
*   **Associated Lab:** **`sections/section-070/module-02/labs/lab-01`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-070/module-02/labs/lab-01
    ```
*   **Hands-on Objective:** Inside `zypperbox`, research candidate intrusion-prevention packages by keyword, pull full metadata for `nginx` without installing it, identify which package provides `/usr/sbin/ip`, and list every installed `python3-*` package using zypper's own filtered search.

---

## Ready for Assessment?

Test your theoretical knowledge and diagnostic reasoning before tackling the capstone mission:

*   **[Take the Section 070 Knowledge Check Quiz](./quiz.md)**

Once you're confident, put both skill sets to work together in one coherent maintenance-window scenario:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-070/capstone/labs/lab-01
```
