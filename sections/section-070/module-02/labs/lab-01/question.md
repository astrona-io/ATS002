# Question

Solve this question on: `terminal`, inside the `zypperbox` container

**Work inside the `zypperbox` container for this entire lab.** Open a shell in it first:

```bash
docker exec -it zypperbox bash
```

Every `zypper` command below runs inside that shell. The Ubuntu host itself has no `zypper` installed. This lab only reads: nothing on `zypperbox` may be installed, removed or updated at any point.

A `/root/answers` directory already exists inside the container. For each research task below, send the command's output into the named file so your findings are recorded.

1. **Keyword search:** You only have a rough keyword, not an exact package name. Use `zypper search` to find candidate packages for intrusion prevention (blocking brute-force login attempts). Save the output to `/root/answers/01-search.txt`. It must name the `fail2ban` package.
2. **Full details, no install:** Use `zypper info` to pull the complete details of the package `nginx` (version, dependencies, description, installed size) without installing it. Save the output to `/root/answers/02-info.txt`. `nginx` must still not be installed afterwards.
3. **Which package supplies a missing command:** A colleague reports that a script fails because the `ip` command is not found. Find which package would have to be installed to provide `/usr/sbin/ip`, without installing anything yet. Save the output to `/root/answers/03-what-provides.txt`.
4. **Filtered installed listing:** List every installed package whose name starts with `python3-`, using `zypper`'s own installed-only search option, not a raw pattern piped through `grep`. Save the output to `/root/answers/04-installed-python3.txt`. Every `python3-` row in it must be marked installed.
