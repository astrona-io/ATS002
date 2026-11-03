# Question

Solve this question on: `terminal`, inside the `zypperbox` container

**Work inside the `zypperbox` container for this entire lab.** Open a shell in it first:

```bash
docker exec -it zypperbox bash
```

Every `zypper` command below runs inside that shell. The Ubuntu host itself has no `zypper` installed. A `/root/answers` directory already exists inside the container for you to save your research findings into.

You are running a maintenance window on an openSUSE Leap 15.6 host (the `zypperbox` container) that follows a conservative, security-focused update policy. Two changes have been requested. Research each one before you act on it; do not guess package names.

1. **Refresh metadata.** Start with `zypper refresh`, so every question below is answered from current data.

2. **Research the first change.** The security team wants intrusion-prevention tooling (blocking brute-force login attempts) added to this host, but they only described the need, not a package name. Use `zypper search` with a keyword to find the right candidate package. Save the search output to `/root/answers/01-research-search.txt`. It must name the candidate package.

3. **Confirm before installing.** Before you install anything, use `zypper info` to pull the candidate package's full details and confirm that its version, size and summary match what you expect. Save that output to `/root/answers/02-research-info.txt`. It must include the package's `Version` field.

4. **Research the second change.** Separately, `telnet-server` has been flagged for removal because it is no longer needed anywhere on this host. Do not assume it is installed: confirm it with `zypper`'s own installed-only search (`zypper search --installed-only`). Save that output to `/root/answers/03-confirm-telnet-installed.txt`. It must show `telnet-server` marked as installed.

5. **Apply the conservative patch policy.** As this host's policy requires, apply only the currently available patches, not a full package update.

6. **Act on your research.** Install the package you identified in steps 2 and 3. Remove `telnet-server`, which you confirmed in step 4.

7. **Close the window.** Review `zypper`'s own operation history to confirm exactly what was done, and in what order.

The grader checks the three answer files, that the package you identified (`fail2ban`) is installed, and that `telnet-server` is no longer installed.
