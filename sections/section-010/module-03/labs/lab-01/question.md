# Question

Solve this question on: `terminal`

Astronaut, the platform team sent two separate requests for this ship.

1.  Load the `dummy` kernel module with two dummy interfaces (`numdummies=2`). It must be loaded now, and both the load and the parameter must survive every future reboot:
    - `/sys/module/dummy/parameters/numdummies` shows `2` right now.
    - A `.conf` file under `/etc/modules-load.d/` loads `dummy` at boot.
    - A `.conf` file under `/etc/modprobe.d/` contains the line `options dummy numdummies=2`.
2.  The `pcspkr` module (the PC speaker beep driver) beeps on every kernel warning. It must never load automatically again, even when hardware detection would normally load it:
    - A `.conf` file under `/etc/modprobe.d/` contains the line `blacklist pcspkr`.
    - `pcspkr` is unloaded now.
    - `pcspkr` stays unloaded after a replayed hardware detection pass (`udevadm trigger`). Do not reboot.

The grader runs `udevadm trigger` itself and checks that `pcspkr` does not come back.
<!-- curriculum-links -->

## Related lessons and assessment

Read [module-03](../../course.md).

The grader checks:

- Confirms the dummy module is loaded with numdummies=2 live, and persists both the load and the parameter across reboots.
- Confirms pcspkr is blacklisted, unloaded now, and stays absent after a udevadm trigger re-detection pass.

Use the inspection commands in the solution to check your work. Submit when you have finished; submission ends this environment.
