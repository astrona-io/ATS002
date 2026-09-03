# Section 020: Scheduled & Containerized Workloads

Welcome to the operational heart of day-to-day system administration. Provisioning a server once is easy. Keeping it running correctly, night after night, without a human sitting at the keyboard, is the real job. In this section, we cover the two mechanisms you will lean on constantly to make that happen: the cron daemon, which fires off commands on a schedule whether or not anyone is watching, and Docker, which packages an application and its dependencies into a single, controllable unit you can start, stop, inspect, and constrain at will.

Both topics look deceptively simple from the outside — "just add a line to a file" and "just run a container" — but each hides sharp edges that trip up administrators who haven't drilled the mechanics. Cron has two competing places to define a job, and picking the wrong one silently misattributes ownership or causes a job to fire twice. Docker containers carry a wall of JSON metadata, and pulling a single fact out of it correctly, under time pressure, is a skill in its own right.

---

## What You Will Master

By completing this section, you will acquire three core operational capabilities:
*   **Per-User Job Scheduling:** How to distinguish system-wide cron sources from per-user crontabs, migrate a job between them without creating a duplicate-execution bug, and express compound day-of-week schedules correctly.
*   **Container Metadata Extraction:** How to use `docker inspect --format` with Go templates to pull a single, precise fact — an IP address, a mount path — out of a container's metadata instead of eyeballing raw JSON.
*   **Constrained Container Launches:** How to start a new detached container with an exact memory ceiling and a host-to-container port mapping, and verify both took effect.

---

## The Learning & Lab Path

This section is divided into two focused modules, each paired with a dedicated hands-on practice lab, and concluded with a Section Capstone Challenge that requires both skills working together:

### 1. Per-User Cron Job Scheduling
*   **Module Reader:** **[Module 1: Per-User Cron Job Scheduling](./module-01/course.md)**
*   **Practice Lab Sandbox:** **`labs/section-020/module-01/lab-01`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-020/module-01/lab-01
    ```
*   **Hands-on Objective:** Migrate a system-wide cronjob on `data-001` into a per-user crontab owned by `asset-manager`, add a new twice-weekly job with a compound day-of-week schedule, and remove the original system-wide entry so the job no longer fires twice.

### 2. Docker Container Lifecycle
*   **Module Reader:** **[Module 2: Docker Container Lifecycle](./module-02/course.md)**
*   **Practice Lab Sandbox:** **`labs/section-020/module-02/lab-01`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-020/module-02/lab-01
    ```
*   **Hands-on Objective:** Stop a running container, extract another container's IP address and volume mount destination using `docker inspect --format`, and launch a new detached container with a hard memory limit and a host-to-container port mapping.

### 3. Section Capstone Challenge
*   **Comprehensive Challenge:** **`labs/section-020/capstone/lab-01` (Scheduled Container Recovery)**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-020/capstone/lab-01
    ```
*   **Hands-on Objective:** Connect the dots. Retire a decommissioned container that is squatting on a needed port, launch its constrained replacement, and schedule a per-user cron job that automatically restarts the new container if it ever stops.

---

## Ready for Assessment?

Test your theoretical knowledge and diagnostic reasoning before tackling the practical lab missions:

*   **[Take the Section 020 Knowledge Check Quiz](./quiz.md)**
