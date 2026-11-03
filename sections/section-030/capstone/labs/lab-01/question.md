# Question

Solve this question on: `terminal`

Your team is setting up a new internal build-agent host in a single maintenance window. Three things must be done on this server before the window closes:

1. A small internal reporting tool, `vmreport`, is provided as source at `/tools/vmreport-1.0.tar.gz`. Build and install it so the binary is at exactly `/usr/local/bin/vmreport`, with **color output disabled**. The tool feeds a monitoring pipeline without a screen that cannot handle ANSI color codes.

2. An existing qcow2 disk image for the new build agent has been staged at `/var/lib/libvirt/images/build-agent.qcow2` on this server, which already runs `libvirtd`. Using the system libvirt instance (`qemu:///system`), define a new **persistent** domain named `build-agent` around this image with **2048 MiB** of memory and **2 virtual CPUs**, attached to the `default` NAT network. Configure it to **autostart** with the host, then **start** it.

3. When both pieces are in place, run `sudo vmreport build-agent` and confirm that it reports the domain as running.

The grader checks that `/usr/local/bin/vmreport` is a compiled program that reports version `1.0` and `color=disabled`; that `build-agent` is persistent, has `Max memory` of 2097152 KiB, 2 CPUs, the `default` network and autostart enabled; that `build-agent` is running; and that `sudo vmreport build-agent` prints `state=running` for it.
