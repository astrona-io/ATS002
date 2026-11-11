# Question

Solve this question on: `terminal`

Astronaut, the `reportd.service` unit on this machine will not start. It is enabled for boot, but right now it is not running: it is in the `failed` state.

Find out why it fails with `systemctl status reportd` and `journalctl -xeu reportd`. Then repair it so that:

- `systemctl is-active reportd` reports `active`
- `systemctl is-enabled reportd` reports `enabled`
- the unit's `ExecStart=` points at a file that exists and can be run
- the daemon really runs its work loop: it adds a line to `/var/lib/reportd/heartbeat.log` every few seconds, so the file keeps growing

Fix the real cause. Do not disable or mask the unit, and do not replace the daemon with a stand-in program. The real daemon program is already on the machine: find where it is, and make the unit point at it.
<!-- curriculum-links -->

## Related lessons and assessment

Read [module-06](../../course.md).

The grader checks:

- Confirms reportd.service is active (running) and enabled for boot, and that it is genuinely writing its heartbeat file - i.e. the ExecStart path was corrected, not just the state forced.

Use the inspection commands in the solution to check your work. Submit when you have finished; submission ends this environment.
