# Question

Solve this question inside the `rpmbox` container. Get a shell with:
```bash
docker exec -it rpmbox bash
```

Someone has handed you `/home/candidate/downloads/logship-agent-2.1.0-1.x86_64.rpm` — an internal monitoring agent, not available in any configured repository.

1. Before installing anything, inspect the package's metadata (version, vendor, declared dependencies) and its full file list.
2. Install it directly with `rpm`.
3. Confirm which already-installed package owns `/usr/bin/python3` (a file that predates this task, owned by the base system's Python package).
4. List every file `logship-agent` placed on the system.
5. Verify that `logship-agent`'s installed files still match what the package originally recorded — no unexpected changes.
6. Query what `logship-agent` requires to run and what capabilities it itself provides.
