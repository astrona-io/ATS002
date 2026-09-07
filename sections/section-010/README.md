# Section 010: Kernel Tuning, Process Limits, and Device Forensics

Welcome to your first major domain in Linux operations and deployment. In this section, we move from treating the running kernel as a sealed black box to treating it as exactly what it is: a live, readable, writable control surface that you are responsible for tuning, ceiling-checking, extending, and diagnosing while a machine is in production.

As an administrator, you will regularly be handed a system mid-incident: a workload that can't fork any more processes, a device that keeps shifting its name out from under a script, a piece of hardware that needs a driver loaded with a very specific parameter, a process that's simply stopped responding and nobody knows why, or a `systemd` service that refuses to start and only leaves you `Job for X failed`. Your mission in this section is to build the exact toolkit for those moments — reading and persisting kernel state, reasoning about the independent ceilings that govern how many processes can exist, managing what code the kernel is running, giving hardware names you can actually trust, catching a misbehaving process in the act, and diagnosing a failed service from its own logs.

---

## What You Will Master

By completing this section, you will acquire six core administrative capabilities:
*   **Live Kernel Introspection & Persistence:** How to read kernel identity and tunable parameters through `sysctl` and `/proc/sys`, and the critical difference between a change that vanishes on reboot and one that survives it.
*   **Process & Thread Ceiling Management:** How to diagnose and raise the three independent ceilings — `kernel.pid_max`, per-user `ulimit -u`, and systemd's `TasksMax=` — that govern whether a workload can fork and thread freely.
*   **Kernel Module Administration:** How to load a module with specific parameters, persist that load and its parameters across reboots, and permanently blacklist a module from ever auto-loading again.
*   **Stable Device Naming with udev:** How to stop depending on kernel-assigned device letters and give a physical disk a name it keeps forever, tied to a stable hardware attribute instead of discovery order.
*   **Live Process Forensics with strace:** How to attach to a running process, filter its syscall stream down to exactly the evidence you need, and safely terminate and clean up only a confirmed offender.
*   **Service Failure Diagnosis with systemctl & journalctl:** How to read a `systemd` unit's own failure report, pull the unit-scoped journal, recognise the four shapes a start-failure takes, and prove a fix holds for both "running now" and "starts on boot".

---

## The Learning & Lab Path

This section is divided into six highly focused, sequential modules. Each module is paired with a dedicated hands-on virtual sandbox practice lab, and concluded with a comprehensive Capstone Integration Challenge:

### 1. Reading and Reshaping the Live Kernel with sysctl
*   **Module Reader:** **[Module 1: Reading and Reshaping the Live Kernel with sysctl](./module-01/course.md)**
*   **Practice Lab Sandbox:** **`labs/section-010/module-01/lab-01`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-010/module-01/lab-01
    ```
*   **Hands-on Objective:** Write the running kernel's release, a live `sysctl` parameter, and the system timezone into `/opt/course/`, using the tool and flag that gives you a clean, script-friendly value every time.

### 2. Process Limits — pid_max, ulimit, and the Three Ceilings
*   **Module Reader:** **[Module 2: Process Limits — pid_max, ulimit, and the Three Ceilings](./module-02/course.md)**
*   **Practice Lab Sandbox:** **`labs/section-010/module-02/lab-01`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-010/module-02/lab-01
    ```
*   **Hands-on Objective:** Diagnose a batch job failing with `fork: retry: Resource temporarily unavailable`, then raise and persist all three independent ceilings that could be capping it — `kernel.pid_max`, the workload user's `ulimit -u`, and the systemd unit's `TasksMax=`.

### 3. Kernel Modules — Loading, Parameters, and Blacklisting
*   **Module Reader:** **[Module 3: Kernel Modules — Loading, Parameters, and Blacklisting](./module-03/course.md)**
*   **Practice Lab Sandbox:** **`labs/section-010/module-03/lab-01`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-010/module-03/lab-01
    ```
*   **Hands-on Objective:** Load the `dummy` module with `numdummies=2` so it persists identically across every future reboot, then permanently blacklist the noisy `pcspkr` module and confirm the block holds against a simulated hardware re-detection pass.

### 4. udev — Giving a Device a Name It Can Keep
*   **Module Reader:** **[Module 4: udev — Giving a Device a Name It Can Keep](./module-04/course.md)**
*   **Practice Lab Sandbox:** **`labs/section-010/module-04/lab-01`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-010/module-04/lab-01
    ```
*   **Hands-on Objective:** Find a backup disk's stable `ATTRS{serial}` attribute and write a custom udev rule that creates persistent `/dev/backup-drive` and `/dev/backup-drive1` symlinks, immune to kernel device-letter reassignment.

### 5. Catching a Process in the Act with strace
*   **Module Reader:** **[Module 5: Catching a Process in the Act with strace](./module-05/course.md)**
*   **Practice Lab Sandbox:** **`labs/section-010/module-05/lab-01`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-010/module-05/lab-01
    ```
*   **Hands-on Objective:** Attach `strace` to three candidate processes, filter for the forbidden `kill()` syscall, resolve the confirmed offender's real executable via `/proc/PID/exe`, and terminate and remove only that process — leaving every innocent process untouched.

### 6. Debugging a Service That Won't Start with systemctl and journalctl
*   **Module Reader:** **[Module 6: Debugging a Service That Won't Start with systemctl and journalctl](./module-06/course.md)**
    1. [The service manager and unit state](./module-06/course-01-service-manager-and-unit-state.md)
    2. [The effective unit definition](./module-06/course-02-the-effective-unit-definition.md)
    3. [Reading the journal](./module-06/course-03-reading-the-journal.md)
    4. [Failure shapes, and proving the fix](./module-06/course-04-failure-shapes-and-proving-the-fix.md)
*   **Practice Lab Sandbox:** **`labs/section-010/module-06/lab-01`** *(to be added)*
*   **Hands-on Objective:** Take a host where `apache2` fails to start, read `systemctl status` and `journalctl -xeu apache2` to find the root cause, fix it, and confirm the unit is both `active` now and `enabled` for boot.

### 7. Section Capstone Challenge
*   **Comprehensive Challenge:** **`labs/section-010/capstone/lab-01` (Kernel, Process, Module & Device Runtime Management Capstone)**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-010/capstone/lab-01
    ```
*   **Hands-on Objective:** Respond to one integrated runaway-telemetry incident: audit live kernel state to a file, raise a fork ceiling a workload is hitting, load and persist a kernel module while permanently blacklisting a noisy one, give a newly attached disk a stable udev name, and diagnose and terminate a hung process caught blocked in `pause()` via `strace`.

---

## Ready for Assessment?

Test your theoretical knowledge and diagnostic reasoning before tackling the practical lab missions:

*   **[Take the Section 010 Knowledge Check Quiz](./quiz.md)**
