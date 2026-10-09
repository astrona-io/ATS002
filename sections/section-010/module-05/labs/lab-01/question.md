# Question

Solve this question on: `terminal`

Astronaut, a security alert came in for this ship. Three processes are running: `collector1`, `collector2` and `collector3`. The alert says that one of them may be making the system call `kill`, which policy forbids, at regular intervals. You can use `strace -p PID` to investigate.

1.  Find the process (or processes) that really call `kill()`. Base your decision on what you observe, not on a guess.
2.  For each process you confirm as guilty:
    - resolve its real program file through `/proc/PID/exe`;
    - terminate the process, so that it is no longer running;
    - remove that program file from disk, and only that file.
3.  Leave every innocent process running, and leave its program file in place.

The grader checks that the guilty process is no longer running and that its program file is gone, and that the innocent processes are still running with their program files intact.
