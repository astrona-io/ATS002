# Summary

Well flown, astronaut. You have finished every part and the mission in this module. Before you move on, look back at what you learned, check yourself, and clean up anything still running.

## What you learned

This module was about finding a process, giving it the right order, and changing its priority.

**From [Finding And Reading Processes](./course-01-finding-and-reading-processes.md):**

- `ps aux` and `ps -eo <columns>` list processes, and `--sort=-pcpu` puts the busiest first.
- `pgrep -a` finds PIDs by name, and `-f` matches the full command line.
- The state letters are `R`, `S`, `D`, `T` and `Z`. A zombie needs its parent fixed (`ps -o ppid= -p <PID>`).

**From [Signals And Stopping Processes](./course-02-signals-and-stopping-processes.md):**

- `kill` sends `SIGTERM` by default. A process can ignore `SIGTERM` and `SIGHUP`, but never `SIGKILL` or `SIGSTOP`.
- Send `SIGTERM` first and `SIGKILL` only after a wait. `pkill` and `killall` select by name.
- `SIGSTOP` freezes a process (state `T`) and `SIGCONT` continues it.

**From [Priority And Jobs](./course-03-priority-and-jobs.md):**

- Niceness runs from -20 to 19. A higher number means less CPU time.
- `nice -n` starts a command with a niceness, `renice -n <value> -p <PID>` changes a running one, and only root may lower it.
- `jobs`, `bg`, `fg` and `nohup` manage the work of your own shell.

## Your missions

| Mission | After the part | What you proved |
| --- | --- | --- |
| [Process Inspection And Control Lab](./labs/lab-01/README.md) | Priority And Jobs | stopped a process that ignores `SIGTERM`, reniced a CPU hog and saved a PID |

If you skipped it, go back to it now.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. Which command lists the five busiest processes by CPU?</summary>

`ps -eo pid,user,pcpu,comm --sort=-pcpu | head -6`. The first line is the heading.
</details>

<details>
<summary>2. A plain <code>kill</code> did not end a process. What do you do?</summary>

Wait a little, then send `kill -KILL <PID>`. `SIGKILL` cannot be ignored.
</details>

<details>
<summary>3. A process shows state <code>Z</code>. Why does <code>kill -9</code> not help?</summary>

It has already finished. Only its table entry remains until the parent collects the result. Fix or end the parent.
</details>

<details>
<summary>4. Which command sets the niceness of PID 4100 to 15?</summary>

`sudo renice -n 15 -p 4100`. Read it back with `ps -o ni= -p 4100`.
</details>

<details>
<summary>5. A normal user cannot lower the niceness of their own process. Why?</summary>

Only root may lower it. A normal user may only raise it.
</details>

## Clean up

Your playground is a whole virtual machine running on your computer. When you are done with this module, remove it, and any mission that is still running.

First, see what is still running:

```sh
astrona list
```

Remove the playground. The command takes its **name**, not its folder path:

```sh
astrona destroy process-control-bay
```

If `astrona list` also showed the mission, remove it the same way:

```sh
astrona destroy ats-002-lab-01a
```

*A signal is an order: `SIGTERM` asks, `SIGKILL` forces, and niceness decides who gets the reactor's time.*

<!-- astrona:playground:destroy -->
