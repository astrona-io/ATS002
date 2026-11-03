# Priority And Jobs

Astronaut, the reactor core hands out slices of time to every crew member. This part shows how to ask for a smaller or a larger slice, and how to manage the work that you start from your own console.

## Niceness is a request for a smaller slice

Each process has a **niceness** from -20 to 19. A high number means "nice to the others", so the process gets less CPU time when the ship is busy. A low number means more CPU time. The default is 0.

<!-- astrona:playground:renew -->

Here is a real example. Read the niceness of the processes of `crew`:

```bash
# shell: any user
ps -u crew -o pid,ni,pcpu,comm
```

The `ni` column shows the niceness. The CPU-burning script has 0 until you change it.

### Starting a command with nice

`nice -n 10 <command>` starts the command with a niceness of 10. If you give no `-n`, `nice` adds 10:

```bash
# shell: any user
nice -n 10 sleep 600 &
ps -o pid,ni,comm -p $!
```

`$!` is the PID of the last background command. The `ni` column should show 10.

### Changing a running process with renice

`renice` changes the niceness of a process that is already running:

```bash
# shell: any user with sudo
sudo renice -n 15 -p "$(pgrep -f cpuburn.sh | head -1)"
ps -o pid,ni,comm -p "$(pgrep -f cpuburn.sh | head -1)"
```

The second command reads the value back. Always read it back.

## Who may change what

A normal user may raise the niceness of their own processes, which makes them nicer. Only root may lower it. A normal user who runs `renice -n -5 -p <PID>` is refused. Root can also change processes of other users, as in the example above.

## Jobs in your own shell

A **job** is a command started from your shell. The shell keeps a numbered list of them.

### See it in your playground

Start a job in the background, look at the list, and bring it back:

```bash
# shell: any user
sleep 300 &
jobs
fg %1
```

`&` at the end starts the command in the background. `jobs` lists the jobs with their numbers. `fg %1` brings job 1 to the foreground, so it holds your console. Press `Ctrl+Z` to freeze it and return to the prompt, then run `bg %1` to let it continue in the background. Press `Ctrl+C` to end it.

### Surviving a logout with nohup

When you close the terminal, the shell sends `SIGHUP` to its jobs and they end. `nohup` starts a command that ignores that signal:

```bash
# shell: any user
nohup sleep 300 > /tmp/sleep.out 2>&1 &
```

Redirecting the output yourself keeps `nohup` from writing a file named `nohup.out` in the current folder.

## Common pitfalls

> [!WARNING]
> - **Thinking a lower number is slower.** A lower niceness means more CPU time, and a higher one means less.
> - **Expecting `renice` to work on a busy-free machine.** Niceness only matters when processes compete for the CPU.
> - **Forgetting that jobs belong to one shell.** `jobs` shows only the jobs of the shell you typed it in.

## Your mission: Process Inspection And Control Lab

You can now find a process, send it the right signal, and change its priority. The mission asks you to stop a process that ignores `SIGTERM`, lower the priority of a CPU hog, and save the PID of a third process into a file, without harming the others.

The mission runs on its own training ship. Pause your playground first, so that it is kept for later:

```sh
astrona stop process-control-bay
```

Then start the mission and open a terminal on it:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/module-07/labs/lab-01
astrona ssh ats-002-lab-01a
```

Read the task in [`question.md`](./labs/lab-01/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-010/module-07/labs/lab-01
```

When the mission is done, remove it and start your playground again:

```sh
astrona destroy ats-002-lab-01a
astrona start process-control-bay
```

*`nice` and `renice` ask for a smaller or larger slice of CPU time, only root may lower the number, and `nohup` keeps a job alive after you log out.*
