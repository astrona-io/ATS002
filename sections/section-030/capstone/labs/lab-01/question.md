# Question

Solve this question on: `terminal`

Your team is standing up a new internal build-agent host in a single maintenance window. Two things need to happen on this server before the window closes:

1. A small internal reporting tool, `vmreport`, is provided as source at `/tools/vmreport-1.0.tar.gz`. Compile and install it so the binary lands at exactly `/usr/local/bin/vmreport`, with color output disabled (this tool feeds a headless monitoring pipeline that can't handle ANSI escape codes).

2. An existing qcow2 disk image for the new build agent has been staged at `/var/lib/libvirt/images/build-agent.qcow2` on this server, which already runs `libvirtd`. Define a new persistent KVM domain named `build-agent` around this image with 2048 MiB of memory and 2 vCPUs, attached to the default NAT network. Configure it to autostart with the host, then start it.

3. Once both pieces are in place, run `vmreport build-agent` and confirm it correctly reports the domain as running.
