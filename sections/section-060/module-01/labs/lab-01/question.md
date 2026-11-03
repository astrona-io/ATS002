# Question

Solve this question on: `terminal`, inside the `rpmbox` container. Get a shell with:
```bash
docker exec -it rpmbox bash
```

If Docker answers with a permission error on the lab machine, run the same command with `sudo` in front.

Astronaut, someone has handed you `/home/candidate/downloads/logship-agent-2.1.0-1.x86_64.rpm`. It is an internal monitoring agent, and no configured repository has it.

1. Before you install anything, inspect the package file: its details (version, vendor), its declared dependencies and its full file list.
2. Install it directly with `rpm`. The installed package must be exactly `logship-agent-2.1.0-1.x86_64`.
3. Find which installed package owns `/usr/bin/python3`. That file was there before this task; it belongs to the base system's Python package.
4. List every file `logship-agent` placed on the system.
5. Verify that the files of `logship-agent` still match what the package recorded at install time. Do not edit any of its files.
6. Query what `logship-agent` needs to run and which capabilities it provides.

The grader checks that `logship-agent-2.1.0-1.x86_64` is installed, that its recorded files include `/usr/bin/logship-agent` and `/etc/logship-agent/agent.conf`, that `rpm -V logship-agent` prints nothing, and that the package declares requirements on `bash` and `coreutils`. Steps 1, 3, 4 and 6 are for your own practice; the grader does not read your answers to them.
