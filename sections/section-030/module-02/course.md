# libvirt Virtual Machine Lifecycle

A container shares the host kernel. A virtual machine does not — it boots its own kernel, runs its own init system, and behaves, from the inside, exactly like a physical computer. Managing that is a genuinely different discipline from managing containers, and on Linux the tool that does it is **libvirt**: a daemon (`libvirtd`, or the newer per-hypervisor `virtqemud`) plus a command-line client (`virsh`) that sit on top of the KVM hypervisor and manage what libvirt calls a **domain** — its own word for "one managed virtual machine."

The contrast with containers is the boundary to keep in mind throughout: a container runtime hands you a process tree in namespaces and shares almost everything with the host; libvirt hands you a raw disk image and makes you state, in one XML document, exactly how much memory the guest gets, how many virtual CPUs, which disk it boots, and which network it plugs into. Everything `virsh` does afterward — starting, stopping, inspecting, autostarting — refers back to that one document, or to a small piece of metadata sitting next to it.

This module is split into five short parts. Work through them in order — each assumes the vocabulary and mechanisms of the ones before it.

## How this module is organised

1. **[Part 1 — The domain and the libvirt stack](./course-01-domain-and-the-libvirt-stack.md)** — what a "domain" is, the `virsh` → `libvirtd` → QEMU/KVM layering, the `qemu:///system` vs `qemu:///session` connection URI, and where each domain's XML definition lives on disk.
2. **[Part 2 — Defining a domain around an existing disk](./course-02-defining-around-an-existing-disk.md)** — `virt-install --import` flag by flag, what `--import` skips, the `default` NAT network, and how the command is just a wrapper around a persistent `define` plus a `start`.
3. **[Part 3 — Persistent vs. transient: the domain lifecycle](./course-03-persistent-vs-transient-lifecycle.md)** — `virsh define` vs `virsh create` on identical XML, the two lifecycle state machines drawn side by side, and why a transient domain vanishes the moment it stops.
4. **[Part 4 — Autostart and reading a domain's true state](./course-04-autostart-and-reading-true-state.md)** — `virsh autostart` as a symlink rather than an XML field, why it does not travel with a domain, and how to read `virsh dominfo` — units and `Max` vs `Used` memory included.
5. **[Part 5 — Graceful shutdown vs. hard power-off](./course-05-graceful-shutdown-vs-hard-destroy.md)** — `virsh shutdown` as an ACPI request the guest can ignore, `virsh destroy` as an immediate process kill, when each is correct, and why neither is the same as `virsh undefine`.

## Learning objectives

After this module you can:

1. **Explain** the layering from `virsh` through `libvirtd`/`virtqemud` to a per-domain QEMU process, and say which layer a given failure sits in.
2. **Choose** the correct connection URI (`qemu:///system`) and explain why a domain defined under `sudo` is invisible to a plain-user `virsh list`.
3. **Write** a `virt-install --import` command that wraps a persistent domain around an existing qcow2 image with a specified memory size, vCPU count, and the `default` NAT network.
4. **Name**, for any `virt-install` flag used, the element it produces in the domain XML.
5. **Explain** the difference between `virsh define` and `virsh create`, and predict what `virsh list --all` shows for each after the domain stops.
6. **Enable** host-boot autostart with `virsh autostart` and **locate** the symlink under `/etc/libvirt/qemu/autostart/` that stores it.
7. **Read** `virsh dominfo` output correctly, converting its KiB memory figures to MiB and distinguishing `Max memory` from `Used memory`.
8. **Distinguish** `virsh shutdown` (asynchronous ACPI request), `virsh destroy` (immediate power-off), and `virsh undefine` (delete the definition), and choose the right one for a hung guest, a clean stop, and a decommission.

## Before you start

Assumed: comfort with a Linux shell, `sudo`, reading and lightly editing XML, and the basic idea of a hypervisor. Section 020's container modules are useful contrast but not a prerequisite. You do **not** need to know QEMU command-line syntax — the point of Part 1 is that libvirt builds it for you.

The playground provides a host with `libvirt`, `virsh`, `virt-install`, and KVM available, the `default` NAT network defined, and at least one pre-populated qcow2 disk image staged under `/var/lib/libvirt/images/` to define a domain around. Every command block states the shell, host, and privilege it assumes; the `virsh destroy` and `virsh shutdown` exercises in Part 5 act on a practice domain only.

## Where this fits

Source builds (Module 1) and this module both take a raw building block — a tarball, a disk image — and make you assemble it with precise control over where it lands and what it can do. A domain defined the wrong way (`create` instead of `define`, or autostart left off) does not fail loudly; it works until the next reboot and then is simply not there. The section capstone combines both skills in one maintenance window, so carry the persistent-vs-transient distinction from Part 3 forward — it is the single idea most likely to be tested as a trap.
