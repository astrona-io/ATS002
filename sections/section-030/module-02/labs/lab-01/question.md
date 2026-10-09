# Question

Solve this question on: `terminal`

An existing qcow2 disk image for a new virtual machine has been staged at `/var/lib/libvirt/images/inventory-db.qcow2` on this host, which already runs `libvirtd`. Work with the system libvirt instance (`qemu:///system`).

1. Define a new **persistent** domain named `inventory-db` around this disk image, with **2048 MiB** of memory and **2 virtual CPUs**, attached to the `default` NAT network.
2. Configure it to **autostart** when the host boots.
3. Start it and confirm that it is running.
4. Perform a graceful shutdown, then a hard power-off, and be ready to explain the state each one leaves the domain in.

The grader checks that `inventory-db` exists, is persistent, has `Max memory` of 2097152 KiB (2048 MiB) and 2 CPUs in `virsh dominfo`, is attached to the `default` network, and has autostart enabled, including its link in `/etc/libvirt/qemu/autostart/`. Steps 3 and 4 are practice: the grader does not check whether the domain is running or stopped at the end.
