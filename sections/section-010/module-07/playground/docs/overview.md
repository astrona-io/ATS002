# Overview: Process Inspection And Control Playground

This is a **playground**, not a lab. The training ship starts clean, runs its preparation script once, and then waits for you. There is no task, no `astrona submit` and no pass or fail. Explore, break things, run `astrona destroy`, and start over.

## What's in the box

Your playground is one ship with a small crew already on duty:

- A single Ubuntu 24.04 `qemu` virtual machine. Reach it with `astrona ssh astro-process-control-bay`.
- The user `crew`, with three background processes started by `systemd-run`:
  - `cpuburn.sh` uses one whole CPU all the time.
  - `stubborn.sh` ignores `SIGTERM`. Only `SIGKILL` ends it.
  - `crew-sleeper.sh` waits quietly and uses almost nothing.
- The scripts live in `/opt/crew/`.
- A helper, `/usr/local/bin/crew-restart`. Run it with `sudo` to start all three processes again after you end one.

## Things to try

- List the crew: `ps -u crew -o pid,ni,pcpu,stat,comm`.
- Find a process by name: `pgrep -a -f stubborn.sh`.
- Send `SIGTERM` to `stubborn.sh`, see it survive, then send `SIGKILL`.
- Freeze `cpuburn.sh` with `SIGSTOP`, look at its state letter, then release it with `SIGCONT`.
- Lower the priority of `cpuburn.sh` with `sudo renice -n 15 -p <PID>` and read the `NI` column again.
- Start a job with `sleep 600 &`, then try `jobs`, `fg` and `bg`.
- Read `/proc/<PID>/status` for any crew process and find the `State` and `PPid` lines.

## When you're done

```sh
astrona destroy process-control-bay
```

`astrona destroy` takes the playground's name, not the folder path. The terminal command uses `astro-process-control-bay`; the `astro-` prefix is optional there. The name for `astrona destroy` is `process-control-bay`.
