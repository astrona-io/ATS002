# Question

Solve this question on: `terminal`

Astronaut, overnight the on-call team flagged several problems on this edge telemetry host, and they all land on your desk at once. Work through them:

1.  **Record the live kernel state first.** Before you change anything, write the running kernel's release string into `/opt/course/audit/kernel-release`, and the current live value of the kernel parameter `vm.swappiness` into `/opt/course/audit/vm-swappiness`. Each file must hold only the value, exactly as the system reports it.

2.  **The ingest side is hitting a limit on new processes.** Raise `kernel.pid_max` to at least `1048576`, both live now and persistently, in a configuration file under `/etc/sysctl.d/` (or in `/etc/sysctl.conf`).

3.  **Two separate kernel module requests came in during the incident:**
    - Load the `dummy` network interface module with four dummy interfaces available (`numdummies=4`). This must keep working the same way after every future reboot: persist both the load itself (in `/etc/modules-load.d/`) and the parameter (in `/etc/modprobe.d/`).
    - The `pcspkr` module has been causing an annoying hardware beep on every kernel warning. It must never load automatically again, even though the hardware that would normally load it is still there. Blacklist it in `/etc/modprobe.d/`, unload it now, and make sure it stays unloaded after a simulated hardware detection pass (`udevadm trigger`), without rebooting.

4.  **A new disk was just attached to this host** to hold telemetry buffer data. It has no stable name yet, only a `/dev/vdX` letter from the kernel that could change at the next boot. Find its hardware serial, and write a custom udev rule under `/etc/udev/rules.d/` that creates a stable `/dev/telemetry-disk` symlink for it, matched by that serial and not by the device letter. Apply the rule now, without rebooting, so that `/dev/telemetry-disk` points at that disk.

5.  **`telemetry-agent.service` has stopped answering health checks:** no CPU use, no log output, nothing. Before you act, attach to its process with `strace` to see what it is blocked on. Once you are sure it is really hung and not just slow, terminate it, so that no `telemetry-agent` process is running.
