# ATS002 - LFCS: Operations Deployment

[![Liberapay](https://img.shields.io/badge/Liberapay-Support_Astrona.io-F6C915?logo=liberapay&logoColor=black&style=for-the-badge)](https://liberapay.com/Astrona.io)

Welcome to **ATS002**, a comprehensive, free training curriculum designed to help you fully master and pass the **Operations Deployment** domain of the **Linux Foundation Certified System Administrator (LFCS)** exam.

Operations Deployment represents **25% of the total LFCS exam weight** — the largest single domain on the exam. This repository bridges theoretical operating system design with real-world, command-line muscle memory, transforming you from a Linux beginner into a confident systems administrator.

---

## The Symmetrical 1:1:1 Learning Framework

To make learning intuitive, digestible, and robust, this curriculum is built around a symmetrical **1:1:1 educational architecture**:

1.  **The Textbook Lesson (`sections/section-XXX/module-YY/course.md`):** Narrative, book-style chapters written in a warm, expert "teacher's voice" that explain *why* the operating system functions the way it does using real-world metaphors, inline command option breakdowns, and clear diagrams.
2.  **The Interactive Quiz (`sections/section-XXX/quiz.md`):** A scenario-based theoretical knowledge check testing diagnostic reasoning, complete with collapsible answers and technical explanation keys.
3.  **The Dedicated Laboratory (`labs/section-XXX/module-YY/`, plus a `labs/section-XXX/capstone/` per section):** A virtual machine sandbox environment launched instantly via the `astrona` CLI where you must solve practical operational objectives and validate your system states using automated testing scripts.

---

## Complete Curriculum & Lab Mapping

The training series is divided into **8 main sections** containing **26 highly focused modules**, **26 targeted lab sandboxes**, and **8 comprehensive Section Capstone Challenges**:

| Section & Domain | Module & Chapter Reader | Practice Lab Sandbox | astrona CLI Run Command |
| :--- | :--- | :--- | :--- |
| **010: Kernel & Process Runtime** | [M1: sysctl](sections/section-010/module-01/course.md) | [lab](labs/section-010/module-01/lab-01) | `astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-010/module-01/lab-01` |
| | [M2: Process/Thread Ceilings](sections/section-010/module-02/course.md) | [lab](labs/section-010/module-02/lab-01) | `astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-010/module-02/lab-01` |
| | [M3: Kernel Modules](sections/section-010/module-03/course.md) | [lab](labs/section-010/module-03/lab-01) | `astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-010/module-03/lab-01` |
| | [M4: udev Device Naming](sections/section-010/module-04/course.md) | [lab](labs/section-010/module-04/lab-01) | `astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-010/module-04/lab-01` |
| | [M5: strace Process Forensics](sections/section-010/module-05/course.md) | [lab](labs/section-010/module-05/lab-01) | `astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-010/module-05/lab-01` |
| | **Section Capstone Challenge** | **[capstone](labs/section-010/capstone/lab-01)** | `astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-010/capstone/lab-01` |
| **020: Scheduled & Container Workloads** | [M1: Per-User Cron](sections/section-020/module-01/course.md) | [lab](labs/section-020/module-01/lab-01) | `astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-020/module-01/lab-01` |
| | [M2: Docker Lifecycle](sections/section-020/module-02/course.md) | [lab](labs/section-020/module-02/lab-01) | `astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-020/module-02/lab-01` |
| | **Section Capstone Challenge** | **[capstone](labs/section-020/capstone/lab-01)** | `astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-020/capstone/lab-01` |
| **030: Building & Virtualizing** | [M1: Compile From Source](sections/section-030/module-01/course.md) | [lab](labs/section-030/module-01/lab-01) | `astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-030/module-01/lab-01` |
| | [M2: libvirt VM Lifecycle](sections/section-030/module-02/course.md) | [lab](labs/section-030/module-02/lab-01) | `astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-030/module-02/lab-01` |
| | **Section Capstone Challenge** | **[capstone](labs/section-030/capstone/lab-01)** | `astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-030/capstone/lab-01` |
| **040: Mandatory Access Control** | [M1: AppArmor & SELinux](sections/section-040/module-01/course.md) | [lab](labs/section-040/module-01/lab-01) | `astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-040/module-01/lab-01` |
| | **Section Capstone Challenge** | **[capstone](labs/section-040/capstone/lab-01)** | `astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-040/capstone/lab-01` |
| **050: Debian Package Management** | [M1: Repos & Pinning](sections/section-050/module-01/course.md) | [lab](labs/section-050/module-01/lab-01) | `astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-050/module-01/lab-01` |
| | [M2: dpkg Low-Level](sections/section-050/module-02/course.md) | [lab](labs/section-050/module-02/lab-01) | `astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-050/module-02/lab-01` |
| | [M3: APT Basics](sections/section-050/module-03/course.md) | [lab](labs/section-050/module-03/lab-01) | `astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-050/module-03/lab-01` |
| | [M4: APT Info Lookup](sections/section-050/module-04/course.md) | [lab](labs/section-050/module-04/lab-01) | `astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-050/module-04/lab-01` |
| | [M5: APT Groups & Bulk Ops](sections/section-050/module-05/course.md) | [lab](labs/section-050/module-05/lab-01) | `astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-050/module-05/lab-01` |
| | **Section Capstone Challenge** | **[capstone](labs/section-050/capstone/lab-01)** | `astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-050/capstone/lab-01` |
| **060: RPM/DNF Package Management** | [M1: RPM Low-Level](sections/section-060/module-01/course.md) | [lab](labs/section-060/module-01/lab-01) | `astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-060/module-01/lab-01` |
| | [M2: RPM DB Rebuild](sections/section-060/module-02/course.md) | [lab](labs/section-060/module-02/lab-01) | `astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-060/module-02/lab-01` |
| | [M3: DNF Basics](sections/section-060/module-03/course.md) | [lab](labs/section-060/module-03/lab-01) | `astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-060/module-03/lab-01` |
| | [M4: DNF Info Lookup](sections/section-060/module-04/course.md) | [lab](labs/section-060/module-04/lab-01) | `astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-060/module-04/lab-01` |
| | [M5: DNF Package Groups](sections/section-060/module-05/course.md) | [lab](labs/section-060/module-05/lab-01) | `astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-060/module-05/lab-01` |
| | **Section Capstone Challenge** | **[capstone](labs/section-060/capstone/lab-01)** | `astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-060/capstone/lab-01` |
| **070: SUSE Package Management** | [M1: Zypper Basics](sections/section-070/module-01/course.md) | [lab](labs/section-070/module-01/lab-01) | `astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-070/module-01/lab-01` |
| | [M2: Zypper Info Lookup](sections/section-070/module-02/course.md) | [lab](labs/section-070/module-02/lab-01) | `astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-070/module-02/lab-01` |
| | **Section Capstone Challenge** | **[capstone](labs/section-070/capstone/lab-01)** | `astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-070/capstone/lab-01` |
| **080: System Disaster Recovery** | [M1: chroot Root Repair](sections/section-080/module-01/course.md) | [lab](labs/section-080/module-01/lab-01) | `astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-080/module-01/lab-01` |
| | [M2: Password Reset](sections/section-080/module-02/course.md) | [lab](labs/section-080/module-02/lab-01) | `astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-080/module-02/lab-01` |
| | [M3: Partition Table Backup](sections/section-080/module-03/course.md) | [lab](labs/section-080/module-03/lab-01) | `astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-080/module-03/lab-01` |
| | [M4: GRUB Recovery](sections/section-080/module-04/course.md) | [lab](labs/section-080/module-04/lab-01) | `astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-080/module-04/lab-01` |
| | **Section Capstone Challenge** | **[capstone](labs/section-080/capstone/lab-01)** | `astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-080/capstone/lab-01` |

---

## How to Navigate This Course

To get the most value out of this curriculum, follow this step-by-step roadmap:

1.  **Enter a Domain Portal:** Navigate into a domain directory, such as `sections/section-010/`, and open its `README.md` to review the section's core philosophy and administrative master competencies.
2.  **Read the Chapters:** Open and read the narrative chapters in order (e.g., `module-01/course.md` and then `module-02/course.md`). Focus on the metaphors, diagrams, and inline command breakdowns.
3.  **Take the Chapter Self-Check:** Challenge yourself with the conceptual questions at the bottom of the course modules.
4.  **Test Your Diagnostics:** Open `quiz.md` inside that section and answer its scenario questions. Expand the HTML details tags to read the deep-dive teacher's explanations.
5.  **Practice the Sandboxes:** Run the targeted module labs (e.g., `labs/section-010/module-01/lab-01`, `labs/section-010/module-02/lab-01`, …) to build muscle memory on atomic configurations.
6.  **Conquer the Capstone Challenges:** Ready for high-stakes practice? Boot up the section's comprehensive **Capstone Challenge Lab** (e.g., `labs/section-010/capstone/lab-01`, `labs/section-020/capstone/lab-01`, etc.), solve the integration prompts, and run the automated test validation suites to confirm your passing state.
7.  **Simulate the Exam:** Once you have completed all 26 modules, open **`sections/final-domain-quiz.md`** and complete the final domain exam simulator under a time cap to audit your readiness.

---

## A Note on Multi-Distro Package Management

Sections 050, 060, and 070 each teach a different Linux family's native package manager (Debian/APT, RHEL-family/DNF, and SUSE/Zypper). This platform's only VM image is Ubuntu 24.04, so section 050 runs natively, while sections 060 and 070 each install Docker on the Ubuntu VM and run the real RHEL-family or SUSE tooling inside a genuine, long-lived container (`rpmbox` and `zypperbox` respectively) — nothing about the package management itself is simulated, only the host it runs on is virtualized. Every module and lab that uses this pattern explains it plainly before diving in.

Section 080 similarly re-stages boot-breaking recovery scenarios (chroot repair, password reset, GRUB corruption) onto a disposable secondary disk or the VM's own next-boot configuration, so the grading VM always stays fully reachable over SSH — the exact commands are practiced in the exact order, just against a target built specifically so a mistake costs nothing.

Section 040 teaches AppArmor hands-on (the MAC system Ubuntu actually enforces) and covers SELinux as a fully worked conceptual walkthrough, since real SELinux enforcement cannot be reliably enabled on this platform's Ubuntu image.

---

## Support This Project

ATS002 is free LFCS training material. If it helped you on your administrative journey, consider supporting ongoing work and resource development via [Liberapay](https://liberapay.com/Astrona.io).
