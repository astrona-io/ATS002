# Question

**Work inside the `zypperbox` container for this entire lab.** Shell in first:

```bash
docker exec -it zypperbox bash
```

Every zypper command below runs inside that shell — the Ubuntu host itself has no zypper installed. An `/root/answers` directory already exists inside the container for you to save your research findings into, exactly as in the module-02 lab.

You are running a maintenance window on an openSUSE Leap 15.6 host (the `zypperbox` container), following a conservative, security-focused update policy. Two changes have been requested — research each one before acting on it, don't just guess at package names.

1. **Refresh metadata.** Start with `zypper refresh` so every question below is answered against current data.

2. **Research the first change.** The security team wants intrusion-prevention / brute-force-blocking tooling added to this host, but only described the need — not an exact package name. Use `zypper search` with a functional keyword to identify the right candidate package. Save the search output to `/root/answers/01-research-search.txt`.

3. **Confirm before installing.** Before installing anything, pull the candidate package's full metadata with `zypper info` to confirm its version, size, and summary actually match what's expected. Save that output to `/root/answers/02-research-info.txt`.

4. **Research the second change.** Separately, `telnet-server` has been flagged for removal as no longer needed anywhere on this host. Rather than assuming it's actually installed, confirm it with zypper's own installed-only search (`zypper search --installed-only`). Save that confirmation to `/root/answers/03-confirm-telnet-installed.txt`.

5. **Apply the conservative patch policy.** Per this host's policy, apply only the currently available curated patches — not a full package update.

6. **Act on your research.** Install the package you identified in Step 2/3. Remove `telnet-server`, which you confirmed in Step 4.

7. **Close the window.** Review zypper's own operation history to confirm exactly what was done, and in what order.
