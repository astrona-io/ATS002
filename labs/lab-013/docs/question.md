# Question

Solve this question on: `terminal`

Two independent requests came in from the platform team for this system:

1.  The `dummy` network interface module needs to be loaded with two dummy interfaces available (`numdummies=2`), and this must keep working identically after every future reboot (both the load itself and the parameter need to persist).
2.  The `pcspkr` module (PC speaker beep driver) has been triggering an annoying hardware beep on every kernel warning, and it must never load automatically again — even though the underlying hardware would normally cause it to be auto-detected and loaded. Unload it now, and confirm the blacklist holds against a simulated hardware re-detection pass (`udevadm trigger`), without rebooting.
