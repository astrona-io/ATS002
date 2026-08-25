# Question

Solve this question on: `terminal`

Overnight, the on-call rotation flagged a cluster of problems on this edge telemetry host, all landing on your desk at once. Work through them:

1.  **Audit the live kernel state first.** Before changing anything, record the running kernel's release string into `/opt/course/audit/kernel-release`, and the current live value of the `vm.swappiness` kernel parameter into `/opt/course/audit/vm-swappiness`.

2.  **The ingest side is hitting a fork ceiling.** Raise `kernel.pid_max` to at least `1048576`, both live and persistently (a config file under `/etc/sysctl.d/`).

3.  **Two independent kernel module requests came in during the incident:**
    - The `dummy` network interface module needs to be loaded with four dummy interfaces available (`numdummies=4`), and this must keep working identically after every future reboot (both the load itself and the parameter need to persist).
    - The `pcspkr` module has been triggering an annoying hardware beep on every kernel warning during the incident and must never load automatically again, even though the hardware that would normally trigger it is still present. Unload it now, and confirm the blacklist holds against a simulated hardware re-detection pass (`udevadm trigger`), without rebooting.

4.  **A new disk was just attached to this host** to receive telemetry buffer data. It has no stable name yet — only a kernel-assigned `/dev/vdX` letter that could shift on the next reboot. Find its stable hardware serial attribute and write a custom udev rule under `/etc/udev/rules.d/` that creates a persistent `/dev/telemetry-disk` symlink for it, matched by that serial rather than the device letter. Apply the rule live, without rebooting.

5.  **`telemetry-agent.service` has stopped responding to health checks entirely** — no CPU usage, no log output, nothing. Attach to its process with `strace` to confirm exactly what it's blocked on before you act. Once you've confirmed it's genuinely hung and not just slow, terminate it.
