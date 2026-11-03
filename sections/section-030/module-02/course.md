# libvirt Virtual Machine Lifecycle

Astronaut, a container is a sealed pod docked to your ship: it shares the ship's reactor core, the kernel. A virtual machine does not. It is a smaller ship flown inside your hangar, with its own reactor: it boots its own kernel, runs its own init system and behaves, from the inside, like a real computer. On Linux the hangar control system for these smaller ships is **libvirt**, a daemon (`libvirtd`, or the newer `virtqemud`) plus a control console (`virsh`). Together they sit on top of the KVM hypervisor and manage what libvirt calls a **domain**, its word for one managed virtual machine.

libvirt hands you a raw disk image and makes you state, in one XML document, exactly how much memory the guest gets, how many virtual CPUs, which disk it boots and which network it plugs into. That document is the ship's blueprint. Everything `virsh` does later, such as starting, stopping, inspecting and autostarting, refers back to it, or to a small piece of extra information stored next to it.

## Learning objectives

After this module you can:

1. **Explain** the layers from `virsh` through `libvirtd` or `virtqemud` to one QEMU process per domain, and say which layer a given failure sits in.
2. **Choose** the correct connection URI (`qemu:///system`) and explain why a domain defined under `sudo` is invisible to a plain-user `virsh list`.
3. **Write** a `virt-install --import` command that wraps a persistent domain around an existing qcow2 image with a given memory size, number of virtual CPUs and the `default` NAT network.
4. **Name**, for each `virt-install` flag used, the element it produces in the domain XML.
5. **Explain** the difference between `virsh define` and `virsh create`, and predict what `virsh list --all` shows for each after the domain stops.
6. **Turn on** host-boot autostart with `virsh autostart` and **find** the symlink under `/etc/libvirt/qemu/autostart/` that stores it.
7. **Read** `virsh dominfo` output correctly, converting its KiB memory figures to MiB and telling `Max memory` from `Used memory`.
8. **Tell apart** `virsh shutdown` (a request the guest can ignore), `virsh destroy` (an immediate power-off) and `virsh undefine` (delete the definition), and choose the right one for a hung guest, a clean stop and a retired machine.

## Before you start

Check that you have the knowledge this module expects, and get to know your playground.

### What you should already know

- **How to work in a Linux shell with `sudo`.** Most commands here need the captain's authority.
- **How to read XML.** You will read and lightly edit small XML documents.
- **What a hypervisor is, roughly.** It is the software that lets one computer run several virtual machines.

You do **not** need to know the QEMU command line. libvirt builds it for you.

### What is in your playground

Your playground is one Ubuntu 24.04 training ship that acts as the hangar. It has `libvirt`, `virsh` and `virt-install` installed, `libvirtd` running, and the `default` NAT network active. An **empty** 2 GiB qcow2 disk is waiting at `/var/lib/libvirt/images/inventory-db.qcow2`, so you can define a domain around it. Nested KVM may be missing on this host. Then libvirt falls back to software emulation, and every lifecycle step behaves the same.

The hands-on steps build on each other: you define `inventory-db` once and then reuse it, so work through them in order on one running playground. After a mission, the playground starts clean; the steps show how to define `inventory-db` again where it is needed. Every command block says which shell, host and rights it expects.

Start the playground with `astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-030/module-02/playground`, then open a terminal on it with `astrona ssh astro-libvirt-vm-lifecycle`. When you are finished, remove it with `astrona destroy libvirt-vm-lifecycle` (that command takes the name `libvirt-vm-lifecycle`, without the `astro-` prefix).

<!-- astrona:playground -->

## How this module is laid out

1. [The Domain And The libvirt Stack](./course-01-domain-and-the-libvirt-stack.md): what a domain is, the `virsh` → `libvirtd` → QEMU layers, and the `qemu:///system` versus `qemu:///session` connection URI.
2. [The Domain XML Definition](./course-02-the-domain-xml-definition.md): the XML document as the domain's blueprint, its persistent and live versions, and where it lives on disk.
3. [Defining A Domain Around An Existing Disk](./course-03-defining-around-an-existing-disk.md): `virt-install --import` flag by flag, what `--import` skips, the `default` NAT network, and the `define` plus `start` underneath.
4. [Persistent Vs Transient: The Domain Lifecycle](./course-04-persistent-vs-transient-lifecycle.md): `virsh define` versus `virsh create` on the same XML, the two lifecycles side by side, and why a transient domain vanishes when it stops.
5. [Autostart And Reading A Domain's True State](./course-05-autostart-and-reading-true-state.md): `virsh autostart` as a symlink rather than an XML field, and how to read `virsh dominfo`, units and `Max` versus `Used` memory included.
   - Mission: [Transient to Persistent Domain Lab](./labs/lab-02/question.md)
   - Mission: [Reconfigure a Persistent Domain Lab](./labs/lab-03/question.md)
6. [Graceful Shutdown Vs Hard Power-Off](./course-06-graceful-shutdown-vs-hard-destroy.md): `virsh shutdown` as a request the guest can ignore, `virsh destroy` as an immediate stop, when each is right, and why neither is `virsh undefine`.
   - Mission: [libvirt Virtual Machine Lifecycle Lab](./labs/lab-01/question.md)
7. [Wrap-Up: Mission Debrief](./course-07-wrap-up.md)

## Why this matters

A domain defined the wrong way does not fail loudly. Started with `create` instead of `define`, or left without autostart, it works fine until the next stop or reboot, and then it is simply not there. The difference between a persistent and a transient domain is the single idea most likely to be tested as a trap, so it is worth getting completely right.
