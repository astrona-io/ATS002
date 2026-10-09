# Section 030: Building & Virtualizing Systems

Welcome, astronaut. Package managers cover most of a system administrator's daily needs, but not all of them. Sometimes the software you need only comes as a source tarball, a kit of parts with no ready-made package. Sometimes the workload needs a whole second operating system, kept apart from the host by its own kernel, not just a container. This section covers both: building and installing software from source, and running full virtual machines with libvirt.

The two skills look unrelated, but they have one thing in common. Each hands you a raw building block, a source tarball or a disk image, and you must put it together yourself, with exact control over where it lands and what it can do. Mistakes here are not cosmetic. A binary installed at the wrong path fails the task that needed it there, and a virtual machine defined the wrong way can vanish the moment it stops.

## What you will learn

By the end of this section you can:

- **Build software from source:** unpack a tarball correctly, find a project's install-path and feature flags with its own `./configure --help`, and prove after `make install` that both landed as intended.
- **Manage the libvirt domain lifecycle:** define a persistent domain around an existing disk image with `virt-install --import`, and explain why persistent (`define`) and transient (`create`) domains behave so differently once they stop.
- **Stop virtual machines the right way:** tell `virsh shutdown` (a request the guest can ignore) from `virsh destroy` (an immediate power-off), and know when each is right.

## The modules

The section has two modules. Each one ends with graded missions right after the parts they practise.

### Compile & Install From Source

[Compile & Install From Source](./module-01/course.md) teaches the `tar`, `./configure`, `make` and `make install` steps, how to choose the right flags, and how to check the installed program. Its mission asks you to build a terminal web browser from source to an exact path with IPv6 switched off. This module has no playground.

### libvirt Virtual Machine Lifecycle

[libvirt Virtual Machine Lifecycle](./module-02/course.md) teaches the libvirt layers, the domain XML, `virt-install --import`, persistent versus transient domains, autostart, `virsh dominfo`, and `shutdown` versus `destroy`. It comes with a playground, the `libvirt-vm-lifecycle` hangar, and three missions: make a transient domain persistent, give a domain more memory and CPUs for good, and define a new domain from scratch.

## Section capstone: New Toolchain, New Host

The capstone joins both skills in one maintenance window. You build a reporting tool from source at an exact path with one feature switched off, then define, autostart and start a persistent libvirt domain, and finally use the tool to report on the domain.

Start it and open a terminal on it:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-030/capstone/labs/lab-01
astrona ssh ats-002-lab-030
```

Read the task in [`question.md`](./capstone/labs/lab-01/question.md). When you think you are done, send it for grading, and remove it afterwards:

```bash
astrona submit -c sections/section-030/capstone/labs/lab-01
astrona destroy ats-002-lab-030
```

## Ready for assessment?

Test your knowledge and your reasoning before the capstone with the [knowledge check quiz](./quiz.md).
