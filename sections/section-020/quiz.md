# Section 020 Knowledge Check: Scheduled & Containerized Workloads

Astronaut, test what you know before you take on the capstone. The questions cover system-wide and per-user cron jobs, `docker stop` and `docker kill`, and pulling exact facts out of `docker inspect` with Go templates.

---

## Scenario-Based Questions

Each question describes a real situation on a training ship. Pick one answer, then open the answer box to check your reasoning.

### Question 1
You are migrating a job off `/etc/cron.d/data-sync`, which currently reads `45 3 * * * etl-runner /opt/scripts/sync.sh`, into the crontab owned by the user `etl-runner`. You run `sudo crontab -u etl-runner -e` and paste the line in completely unchanged, then save. What actually happens at 3:45am?
*   **A)** The job runs correctly, since `etl-runner` is simply a valid path component.
*   **B)** Cron treats `etl-runner` as the first word of the command itself, tries to execute a program by that name, and `/opt/scripts/sync.sh` never runs.
*   **C)** `crontab -e` refuses to save the file and prints a syntax error before you can exit the editor.
*   **D)** The job runs twice — once as `etl-runner` and once as `root`.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** A system-wide cron line has six fields: five time fields plus a required username field. A per-user crontab line has only the five time fields and then the command, because the owner is already clear from whose crontab it is. If you paste a six-field line into a per-user crontab and keep the username, you get no helpful error. Cron treats the leftover username as the first word of the command and tries to run a program with that name. That fails silently at the scheduled time, with nobody watching.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because `etl-runner` is not a valid executable name in `$PATH`, so the "command" cron actually tries to run fails.
    *   *Option C* is incorrect because the line has a wrong command, not a syntax error. `crontab` checks the structure of the fields, not whether the command makes sense.
    *   *Option D* is incorrect because nothing in this scenario schedules the job to run under two different accounts; it was moved, not duplicated.
</details>

---

### Question 2
You are logged in as root and need to add a new job to the `dataproc` service account's crontab. Which command correctly does this?
*   **A)** `crontab -e`
*   **B)** `sudo crontab -u dataproc -e`
*   **C)** `sudo nano /var/spool/cron/crontabs/dataproc`
*   **D)** `crontab -u dataproc`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** The `-u <user>` option tells `crontab` to work on that account's spool file instead of your own. Working on another account's crontab needs root rights, which is why the command starts with `sudo`. `-e` opens the crontab for editing.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because plain `crontab -e`, run as root, edits *root's own* crontab — not `dataproc`'s. This is the single most common mistake when migrating a job to a service account.
    *   *Option C* is incorrect because hand-editing the spool file directly bypasses `crontab`'s syntax validation and can leave behind a file with permissions or formatting cron refuses to trust.
    *   *Option D* is incorrect because it is missing `-e` (or `-l`). Without an action option, `crontab` waits for a complete crontab file on standard input (stdin) to install, which is not the same as opening an editor.
</details>

---

### Question 3
After migrating a job from `/etc/cron.d/asset-cleanup` into `asset-manager`'s per-user crontab, an administrator notices duplicate log entries appearing every night at 8:30pm. What is the most likely cause, and the correct fix?
*   **A)** The minute field needs to be offset slightly to avoid a scheduling collision.
*   **B)** The original `/etc/cron.d/asset-cleanup` file was never deleted, so the same command is now scheduled from two independent sources; delete the original file.
*   **C)** Cron always executes any newly added job twice on its first scheduled run.
*   **D)** The per-user crontab line is missing a username field, causing cron to run it under two identities.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** Cron never removes duplicates. If the same command is scheduled in a system-wide file and in a per-user crontab, it runs twice, once from each, at the same time. A move is not finished until you delete the original file (or remove its line) and search again with `grep` to confirm that nothing is left.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because offsetting the time doesn't address the root cause — two independent schedules — it just staggers the duplicate runs instead of eliminating one.
    *   *Option C* is incorrect; cron does not have any built-in "run once extra on first fire" behavior.
    *   *Option D* is incorrect because a per-user crontab line correctly has *no* username field — adding one would break the command, not cause double-execution under two identities.
</details>

---

### Question 4
A task instructs you to "stop the container named `cache_v1`." Which command is the correct default choice, and why?
*   **A)** `docker kill cache_v1` — it terminates the container immediately, which is faster.
*   **B)** `docker stop cache_v1` — it sends `SIGTERM` to the container's PID 1, waits up to a grace period (10 seconds by default) for a clean exit, and only sends `SIGKILL` if it's still alive after that.
*   **C)** `docker rm -f cache_v1` — it stops and removes the container in one step.
*   **D)** `docker pause cache_v1` — it freezes the container's processes without terminating them.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `docker stop` is the correct default whenever a task says "stop" — it gives the container's main process a chance to shut down cleanly via `SIGTERM` before escalating to `SIGKILL`. This is the graceful path and matches what "stop" means in normal operational usage.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because `docker kill` skips the grace period entirely, sending `SIGKILL` immediately — appropriate only for a genuinely hung process ignoring termination signals, not as a default.
    *   *Option C* is incorrect because the task asked to stop the container, not remove it — `docker rm -f` destroys the container object entirely, which is a different and more destructive operation than what was requested.
    *   *Option D* is incorrect because `docker pause` freezes processes in place using cgroups freezer state; it does not stop or terminate anything, and isn't what "stop" means here.
</details>

---

### Question 5
You run `docker inspect --format '{{ .NetworkSettings.IPAddress }}' web_v2` and get empty output, even though `web_v2` is running and reachable over the network. What is the most likely cause, and the correct fix?
*   **A)** The container isn't actually running; it must be restarted first.
*   **B)** `web_v2` is attached to a custom, user-defined network instead of the default bridge — Docker only populates the top-level `.NetworkSettings.IPAddress` field for default-bridge containers. Use `{{ range .NetworkSettings.Networks }}{{ .IPAddress }}{{ end }}` instead.
*   **C)** `docker inspect` requires `sudo` to report IP address fields; without it, the field is silently blanked.
*   **D)** The field name is deprecated in current Docker releases and was renamed to `.NetworkSettings.Address`.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** Docker only fills the top-level `.NetworkSettings.IPAddress` field for containers on the default bridge network. When a container is on a network you created, Docker keeps its address per network instead, under `.NetworkSettings.Networks.<network-name>.IPAddress`. The `range` form goes through that map without you needing to know the network's name, so it is the safer template to use.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because the scenario states the container is running and reachable — the empty field is a template-path issue, not a container-state issue.
    *   *Option C* is incorrect; `docker inspect` does not gate JSON fields behind privilege escalation, and an unprivileged user with Docker socket access sees the same data root would.
    *   *Option D* is incorrect; `.NetworkSettings.IPAddress` is not deprecated or renamed — it's simply left blank when it doesn't apply to the container's network mode.
</details>
