# Question

Solve this question on: `terminal`

Astronaut, this machine is set to boot into `graphical.target`. It is a server with no screen and no graphical login, so it should come up in `multi-user.target` instead.

1. Check the current default with `systemctl get-default`.
2. Change the default boot target to `multi-user.target`, so the next boot uses it.
3. Make sure that `systemctl get-default` reports `multi-user.target`, and that `/etc/systemd/system/default.target` points at `multi-user.target`.

You do **not** need to switch the running system to the new target now. Only change what it boots into. (`systemctl isolate <target>` would switch the *running* system, and adding `systemd.unit=<target>` to the kernel line in the boot loader would change the target for one boot only. Neither is needed here.)
