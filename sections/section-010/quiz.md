# Section 010 Knowledge Check: Kernel Tuning, Process Limits, and Device Forensics

Test your understanding of live kernel parameters, process/thread ceilings, kernel module management, stable device naming, and syscall-level process forensics.

---

## Scenario-Based Questions

### Question 1
You need to record the current value of `net.ipv4.ip_forward` into a script-friendly file containing nothing but the bare value — no parameter name, no `=` sign. Which command accomplishes this correctly?
*   **A)** `sysctl net.ipv4.ip_forward > /opt/course/ip_forward`
*   **B)** `sysctl -n net.ipv4.ip_forward > /opt/course/ip_forward`
*   **C)** `sysctl -w net.ipv4.ip_forward > /opt/course/ip_forward`
*   **D)** `uname -r net.ipv4.ip_forward > /opt/course/ip_forward`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `man sysctl` documents `-n` under `OPTIONS` as disabling the printing of the key, leaving only the bare value. This is exactly the script-friendly form needed when redirecting into a file that must hold nothing but the value itself.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because a bare `sysctl` call prints `net.ipv4.ip_forward = 0` — the key name and an `=` sign are included, polluting the file's contents.
    *   *Option C* is incorrect because `-w` is the *write* flag, used to set a new value, not read the existing one; used without a value to assign, it will not behave as a clean read.
    *   *Option D* is incorrect because `uname` reports kernel identity information (release, version, hostname), not `/proc/sys` tunables — it has no concept of a sysctl parameter name.
</details>

---

### Question 2
A batch job running as the `dataproc` user fails partway through a nightly run with `pthread_create failed`, even though `free -m` and `top` show plenty of idle CPU and memory. You raise `kernel.pid_max` to `4194304`, both live and persistently, and confirm the change with `sysctl -n kernel.pid_max`. The next night, the exact same failure happens again. What is the most likely explanation?
*   **A)** `kernel.pid_max` did not actually persist, so the machine silently reverted it on its own overnight.
*   **B)** The `dataproc` user's own `ulimit -u` (`RLIMIT_NPROC`) ceiling is a separate, independently enforced limit that raising `pid_max` does nothing to change.
*   **C)** `pthread_create` failures are always caused by insufficient memory, regardless of what `free -m` reports.
*   **D)** `kernel.pid_max` only applies to processes, not threads, so a thread-heavy workload was never affected by the change in the first place.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `kernel.pid_max` governs the whole system's shared pool of PID/TID numbers, but a per-user process/thread ceiling (`RLIMIT_NPROC`, surfaced as `ulimit -u`) is a completely separate, independently enforced accounting path scoped to the real UID running the workload. Raising the global pool does nothing to widen a per-user cap that's still capped below what the job needs. If the job runs as a systemd unit, a third ceiling — `TasksMax=` — could also independently be the culprit.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because the scenario states the change was persisted and confirmed — a value that reverts on its own without any recorded cause is not the expected behavior of a correctly persisted sysctl setting.
    *   *Option C* is incorrect because the scenario explicitly rules out memory pressure via `free -m`, and `pthread_create` failures are commonly caused by hitting a process/thread ceiling, not only memory exhaustion.
    *   *Option D* is incorrect because Linux does not maintain a separate thread-ID namespace — every thread consumes a slot from the exact same shared `pid_max` pool as processes.
</details>

---

### Question 3
You need the `dummy` kernel module to load automatically on every future boot, with `numdummies=2` applied every time — not just for the current session. Which pair of files must you create together to achieve both halves of this requirement?
*   **A)** A single file under `/etc/modprobe.d/` containing both the module name and its parameter.
*   **B)** A file under `/etc/modules-load.d/` naming the module, and a separate file under `/etc/modprobe.d/` with an `options` line providing the parameter.
*   **C)** A file under `/etc/sysctl.d/` naming the module, and a file under `/etc/modprobe.d/` with the parameter.
*   **D)** Only a file under `/etc/modules-load.d/` — parameters are inferred automatically from the module's `modinfo -p` defaults.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** These are two deliberately separate, single-purpose file families. `/etc/modules-load.d/*.conf` (read by `systemd-modules-load.service`) answers only "should this module load at boot" — one bare module name per line, with no room for parameters. `/etc/modprobe.d/*.conf`, using an `options` directive, answers "with what arguments" — consulted by `modprobe` and the boot-time loader regardless of what triggered the load. Both files are required together to get a parameterized module loading automatically at boot.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because `/etc/modprobe.d/` alone does not trigger a boot-time load — it only supplies options *if and when* the module is loaded by some other mechanism.
    *   *Option C* is incorrect because `/etc/sysctl.d/` governs live kernel *parameters* under `/proc/sys`, an entirely unrelated subsystem from kernel module loading.
    *   *Option D* is incorrect because `modinfo -p` only shows what parameters a module *accepts* — it never supplies actual runtime values; those must be explicitly configured.
</details>

---

### Question 4
You write a udev rule matching `ATTRS{serial}=="WD-XA123456"` to create a persistent `/dev/backup-drive` symlink, then run `sudo udevadm control --reload-rules`. The disk was already attached before you wrote the rule. When you check `ls -l /dev/backup-drive`, it does not exist. What is the most likely cause?
*   **A)** The rule file was placed in `/etc/udev/rules.d/`, which is the wrong directory for custom rules.
*   **B)** `SYMLINK+=` should have been written as `SYMLINK=` instead, since `+=` only works for already-existing symlinks.
*   **C)** `--reload-rules` only tells udev to re-read the rule files from disk; it does not re-evaluate already-connected devices against the newly loaded rules. A `udevadm trigger` pass is still required.
*   **D)** Custom udev rules can only apply to devices connected after the rule file is created, never to devices already attached at boot.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: C**

*   **Why C is correct:** `udevadm control --reload-rules` and applying those rules to already-present hardware are two genuinely separate steps. Reloading rules tells the running `udevd` daemon to re-read rule files — it does not synthesize new `add`/`change` events for devices that are already sitting there. `sudo udevadm trigger --subsystem-match=block` is required afterward to force udev to re-run its complete rule chain, including the new rule, against already-connected devices. This is a common trap because `--reload-rules` runs cleanly with no error, making it look like it worked.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because `/etc/udev/rules.d/` is precisely the correct, package-manager-untouched location for custom administrator rules — `/lib/udev/rules.d/` and `/usr/lib/udev/rules.d/` are the ones to avoid, since package updates can overwrite them.
    *   *Option B* is incorrect because `SYMLINK+=` is intentionally additive syntax, appending a new symlink name without erasing symlinks the distro's built-in rules already created; a plain `=` would be the wrong, destructive choice here, not the fix.
    *   *Option D* is incorrect because `udevadm trigger` exists specifically to make a custom rule apply to already-attached hardware without requiring a reboot.
</details>

---

### Question 5
You're investigating a process suspected of periodically calling the `kill()` syscall. You run `sudo strace -p 4821 -e trace=kill` and, after a short wait, see the process call `kill()`. Before terminating it, what must you do, and why does the order matter?
*   **A)** Immediately run `sudo kill -9 4821`, since a confirmed offender should be stopped as fast as possible regardless of order.
*   **B)** Run `sudo readlink -f /proc/4821/exe` first to capture the real on-disk executable path, because `/proc/PID/` — and the information it holds — ceases to exist the instant the process is terminated.
*   **C)** Run `ps aux | grep 4821` first to double-check the process's displayed name, since the name is always authoritative for identifying the correct binary.
*   **D)** Order does not matter, since the executable's path on disk never changes regardless of whether the process is still running.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `/proc/PID/exe` is a magic symlink the kernel maintains only while the process is alive, pointing at the exact inode currently mapped as its executable image. The moment the process is killed, `/proc/PID/` disappears entirely — there is nothing left to resolve. Capturing the real, canonicalized path with `readlink -f` *before* terminating the process is the one ordering detail a grader (or a real incident postmortem) is most likely to specifically check for.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because killing first destroys the only reliable evidence of the process's real backing file, potentially leaving a disguised or renamed offending binary untouched on disk while creating a false sense the incident is closed.
    *   *Option C* is incorrect because a process's displayed name (`argv[0]`/`comm`) is not guaranteed to match its actual backing file — it could be a renamed copy, a symlink, or a script whose displayed name is really its interpreter's.
    *   *Option D* is incorrect because while the file itself may not move, your only reliable *means of discovering* its exact path — `/proc/PID/exe` — vanishes together with the process, making order the entire point.
</details>
