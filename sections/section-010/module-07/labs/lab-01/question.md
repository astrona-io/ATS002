# Question

Solve this question on: `terminal`

Three background processes run on this host as the user `crew`. Their scripts are in `/opt/crew/`: `cpuburn.sh`, `stubborn.sh` and `crew-sleeper.sh`.

1. The process running `/opt/crew/stubborn.sh` must be ended. It ignores the normal stop signal, so you must find the signal it cannot ignore.
2. The process running `/opt/crew/cpuburn.sh` uses too much CPU. Do not end it. Change its niceness to **15**.
3. Write the process ID (PID) of the process running `/opt/crew/crew-sleeper.sh` into the file `/opt/course/7/sleeper-pid`. The file must contain only the number. Do not end this process.

The grader checks that no `stubborn.sh` process is running, that `cpuburn.sh` is still running with niceness 15, that `crew-sleeper.sh` is still running, and that `/opt/course/7/sleeper-pid` holds exactly its PID.
