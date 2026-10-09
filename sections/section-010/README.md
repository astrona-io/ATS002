# Section 010: Kernel Tuning, Process Limits, and Device Forensics

Welcome aboard, astronaut. In this section you stop treating the running kernel, the ship's reactor core, as a sealed black box. You learn to read it, tune it, extend it and question it while the ship is flying.

As an administrator, you will often be handed a machine in the middle of a problem. A workload cannot start any more processes. A disk keeps changing its name under a script. A driver must be loaded with one exact setting. A process has stopped answering, and nobody knows why. A `systemd` service refuses to start and leaves only `Job for X failed`. This section builds the toolkit for exactly those moments, and every skill ends with a check command that proves the machine is in the right state, even after a reboot.

## What you will learn

After this section you can:

- **Read and persist kernel settings.** Read the kernel's identity and its live parameters with `uname`, `sysctl` and `/proc/sys`, and tell a change that is gone after a reboot from one that survives it.
- **Raise process and thread limits.** Diagnose and raise the three separate limits that decide whether a workload can start new processes: `kernel.pid_max`, a user's `ulimit -u`, and a service's `TasksMax=`.
- **Manage kernel modules.** Load a module with parameters, make the load and its parameters survive a reboot, and blacklist a module so it never loads automatically.
- **Give devices stable names with udev.** Match a disk by its hardware serial instead of the letter the kernel hands out, so its name never changes.
- **Trace a running process with `strace`.** Attach to a process, filter its system calls down to the evidence you need, and stop only the confirmed offender.
- **Debug a service that will not start.** Read `systemctl status` and `journalctl`, find the first real error, fix it, and prove the service runs now and starts at boot.

## Modules

Work through the modules in order. Each module has a landing page with its goals and its playground, short parts that each teach one idea, graded missions right after the part they practise, and a wrap-up.

### 1. [Reading and Reshaping the Live Kernel with sysctl](./module-01/course.md)

1. Identifying The Running Kernel
2. Every Sysctl Name Is A File
3. Reading The Live Value (mission: sysctl Live Kernel State Lab)
4. Runtime Changes Live In Memory
5. Persistent Changes And Which File Wins
6. Wrap-Up: Mission Debrief

### 2. [Process Limits: pid_max, ulimit, and the Three Ceilings](./module-02/course.md)

1. The Shared PID Pool
2. The Three Independent Ceilings
3. Raising The Kernel And User Ceilings (mission: Process Limits: Diagnose the Single Clamp (ulimit -u) Lab)
4. Raising TasksMax And The Triage Order (missions: Process & Thread Ceilings Lab; Process Limits: Diagnose the Single Clamp (TasksMax) Lab)
5. Wrap-Up: Mission Debrief

### 3. [Kernel Modules: Loading, Parameters, and Blacklisting](./module-03/course.md)

1. Inspecting Modules And Their Parameters
2. Loading Modules With Modprobe
3. Loading Modules At Boot With Options
4. Blacklisting Modules (mission: Kernel Module Loading & Blacklisting Lab)
5. Wrap-Up: Mission Debrief

### 4. [udev: Giving a Device a Name It Can Keep](./module-04/course.md)

1. Device Events And A Stable Identity
2. Writing The udev Rule
3. Applying And Using The Rule (mission: Stable Device Naming with udev Lab)
4. Wrap-Up: Mission Debrief

### 5. [Catching a Process in the Act with strace](./module-05/course.md)

1. From A Name To The Right PIDs
2. Attaching And Filtering The Syscall Stream
3. From Confirmed Process To Safe Cleanup (mission: Process Forensics with strace Lab)
4. Wrap-Up: Mission Debrief

### 6. [Debugging A Service That Will Not Start](./module-06/course.md)

1. The Service Manager And Unit State
2. The Effective Unit Definition
3. Reading The Journal
4. Keeping The Journal (mission: Configure journald: Persistent & Bounded Lab)
5. Bad Commands And Taken Ports (missions: Service Won't Start: Bad ExecStart Path Lab; Service Won't Start: Port Already In Use Lab)
6. Dependencies, Permissions And Restart Loops (missions: Service Won't Start: Permission Denied Lab; Service Won't Start: Failed Dependency & Restart Flap Lab)
7. Proving The Fix And Boot Targets (mission: Set the Default Boot Target Lab)
8. Wrap-Up: Mission Debrief

## Check yourself

Before the final mission, test what you know with the [section knowledge check](./quiz.md). It has scenario questions with explanations for every answer.

## The capstone mission

The section ends with one combined mission: the Kernel, Process, Module & Device Runtime Management Capstone Lab. One edge telemetry host has several problems at once. You record its live kernel state, raise a process limit a workload is hitting, load and persist one kernel module while blacklisting another, give a new disk a stable udev name, and find and stop a hung process with `strace`. The task is in [`capstone/labs/lab-01/question.md`](./capstone/labs/lab-01/question.md).

Start the mission and open a terminal on it:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/capstone/labs/lab-01
astrona ssh ats-002-lab-010
```

When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-010/capstone/labs/lab-01
```

When the mission is done, remove it:

```sh
astrona destroy ats-002-lab-010
```
