# Question

**Work inside the `zypperbox` container for this entire lab.** Shell in first:

```bash
docker exec -it zypperbox bash
```

Every zypper command below runs inside that shell — the Ubuntu host itself has no zypper installed. This lab is entirely read-only: nothing on `zypperbox` should be installed, removed, or updated at any point.

An `/root/answers` directory already exists inside the container. For each research task below, redirect the command's output into the named file so your findings are recorded.

1. **Keyword search:** You only have a rough keyword to go on, not an exact package name. Find candidate packages related to intrusion-prevention / brute-force-blocking functionality using `zypper search`. Save the output to `/root/answers/01-search.txt`.
2. **Full metadata, no install:** For the package `nginx`, pull its complete metadata (version, dependencies, description, installed size) using `zypper info`, without installing it. Save the output to `/root/answers/02-info.txt`.
3. **What provides a missing command:** A colleague reports a script fails because the `ip` command isn't found. Determine which package would need to be installed to provide `/usr/sbin/ip`, without installing anything yet. Save the output to `/root/answers/03-what-provides.txt`.
4. **Filtered installed listing:** List every currently-installed package on the host whose name starts with `python3-`, using zypper's own installed-filtering search flags — not a raw pattern piped through `grep`. Save the output to `/root/answers/04-installed-python3.txt`.
