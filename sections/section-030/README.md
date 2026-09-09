# Section 030: Building & Virtualizing Systems

Welcome to Section 030. Distro package managers cover most of a system administrator's day-to-day needs — until they don't. Sometimes the software you need only ships as a source tarball, with no distro package at all. Sometimes the workload itself needs to be an entire second operating system, isolated from the host at the kernel level, not just a process namespace away. This section covers both situations: compiling and installing software directly from source when a package manager can't help you, and standing up and managing full virtual machines with libvirt when a container isn't isolated enough.

These two skills look unrelated on the surface — one is about a build pipeline, the other about a hypervisor — but they share a common thread. Both hand you a raw building block (a source tarball, a disk image) and require you to assemble it correctly yourself, with precise control over exactly where it lands and exactly what capabilities it ends up with. Get either wrong, and the mistake isn't cosmetic: a binary installed at the wrong path silently fails the task that needed it there, and a VM defined the wrong way can vanish entirely the moment it's stopped.

---

## What You Will Master

By completing this section, you will acquire three core deployment capabilities:
*   **Source Build Pipelines:** How to unpack a tarball correctly, discover a project-specific `configure` script's install-location and feature-toggle flags by reading its own `--help` output, and verify both landed as intended after `make install`.
*   **libvirt Domain Lifecycle:** How to define a persistent KVM domain around an existing disk image with `virt-install --import`, and why persistent (`define`) and transient (`create`) domains behave completely differently the moment they stop.
*   **Graceful vs. Hard VM Shutdown:** How to distinguish `virsh shutdown` (an ACPI request the guest can ignore) from `virsh destroy` (an immediate, unconditional power-off), and when each is the correct call.

---

## The Learning & Lab Path

This section is divided into two focused modules, each paired with a dedicated hands-on practice lab, and concluded with a Section Capstone Challenge that requires both skills working together:

### 1. Compile & Install From Source
*   **Module Reader:** **[Module 1: Compile & Install From Source](./module-01/course.md)**
    1. [Unpacking the tarball, and the build pipeline](./module-01/course-01-unpacking-and-the-build-pipeline.md)
    2. [Discovering and choosing configure flags](./module-01/course-02-discovering-and-choosing-flags.md)
    3. [Building, installing, and verifying](./module-01/course-03-building-installing-verifying.md)
*   **Practice Lab Sandbox:** **`labs/section-030/module-01/lab-01`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-030/module-01/lab-01
    ```
*   **Hands-on Objective:** Extract a `.tar.bz2` source tarball staged on the host, discover the project's install-location and IPv6 feature-toggle flags by reading `./configure --help`, then build and install the binary so it lands at the exact path `/usr/bin/links` with IPv6 support compiled out.

### 2. libvirt Virtual Machine Lifecycle
*   **Module Reader:** **[Module 2: libvirt Virtual Machine Lifecycle](./module-02/course.md)**
    1.  [The domain and the libvirt stack](./module-02/course-01-domain-and-the-libvirt-stack.md)
    2.  [Defining a domain around an existing disk](./module-02/course-02-defining-around-an-existing-disk.md)
    3.  [Persistent vs. transient — the domain lifecycle](./module-02/course-03-persistent-vs-transient-lifecycle.md)
    4.  [Autostart and reading a domain's true state](./module-02/course-04-autostart-and-reading-true-state.md)
    5.  [Graceful shutdown vs. hard power-off](./module-02/course-05-graceful-shutdown-vs-hard-destroy.md)
*   **Practice Lab Sandboxes:**
    1. **`labs/section-030/module-02/lab-01`** — define a new persistent KVM domain `inventory-db` around an existing qcow2 disk (2048 MiB, 2 vCPUs, default NAT network), configure autostart, then demonstrate a graceful `virsh shutdown` and a hard `virsh destroy`.
    2. **`labs/section-030/module-02/lab-02`** — a domain is running but **transient** (`virsh create`, no definition on disk); promote it to persistent in place with `virsh define`, without stopping it, then enable autostart and prove it now survives a `virsh destroy`.
    3. **`labs/section-030/module-02/lab-03`** — an existing persistent domain is under-provisioned (512 MiB, 1 vCPU); raise it to 2048 MiB / 2 vCPU in the **persistent** config (`virsh edit`, or `virsh set*` with `--config`), start it, and verify with `virsh dominfo`.
*   **Lab Run Commands:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-030/module-02/lab-01
    astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-030/module-02/lab-02
    astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-030/module-02/lab-03
    ```

### 3. Section Capstone Challenge
*   **Comprehensive Challenge:** **`labs/section-030/capstone/lab-01` (New Toolchain, New Host)**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-030/capstone/lab-01
    ```
*   **Hands-on Objective:** Connect the dots. Compile and install a build-status reporting tool from source at a precise path with a feature disabled, then define, autostart, and stand up a persistent libvirt domain for a new internal service — a single maintenance window that touches both a build pipeline and a hypervisor.

---

## Ready for Assessment?

Test your theoretical knowledge and diagnostic reasoning before tackling the practical lab missions:

*   **[Take the Section 030 Knowledge Check Quiz](./quiz.md)**
