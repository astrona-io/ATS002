# Question

Solve this question on: `terminal`

An existing qcow2 disk image for a lab VM has been staged at `/var/lib/libvirt/images/inventory-db.qcow2` on this host, which already runs `libvirtd`.

1. Define a new persistent KVM domain named `inventory-db` around this disk image with 2048 MiB of memory and 2 vCPUs, attached to the default NAT network.
2. Configure it to autostart when the host boots.
3. Start it and confirm it is running.
4. Perform a graceful shutdown, then separately perform a hard power-off, and be prepared to explain the difference in the state each leaves the domain in.
