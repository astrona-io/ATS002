# Question

Solve this question on: `terminal`

There was a security alert you need to follow up on. Three processes are running on this system: `collector1`, `collector2`, and `collector3`. It was alerted that one of these might be running the per-policy forbidden syscall `kill` periodically. You can use `strace -p PID` to investigate.

Find the process (or processes) that actually calls `kill()`. For each one confirmed guilty: resolve its real backing executable via `/proc/PID/exe`, terminate the process, and remove only that confirmed executable. Leave any innocent process(es) running, untouched.
