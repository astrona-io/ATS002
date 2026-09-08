# Question

Solve this question on: `terminal`

This host is currently configured to boot into `graphical.target`, but it is
a headless server with no display manager — it should come up in
`multi-user.target` instead.

1. Confirm the current default with `systemctl get-default`.
2. Change the default boot target to `multi-user.target` so the next boot
   uses it.
3. Verify: `systemctl get-default` reports `multi-user.target`, and
   `/etc/systemd/system/default.target` resolves to it.

You do **not** need to switch the running system's target right now — only
change what it boots into. (For reference: `systemctl isolate
<target>` switches the *running* system, and appending
`systemd.unit=<target>` at the boot loader overrides it for one boot.)
