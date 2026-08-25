# LFCS Operations Deployment Domain Certification Quiz

Welcome to the Final Domain Certification Quiz for the **LFCS Operations Deployment** curriculum. This comprehensive test contains **20 high-signal, scenario-based system administration questions** covering representative competencies across all 26 modules inside our 8 operations sections.

To simulate actual Linux Foundation exam pressure:
*   Answer all 20 questions without consulting external documentation or manual shell helpers.
*   Allow yourself a maximum of **30 minutes** to complete the entire test.
*   Once finished, scroll to the very bottom to check the **Audit and Review Key** to trace any incorrect answers back to their exact section and module chapters.

---

## The Exam Simulator

### Question 1
You need to write the live value of `net.ipv4.ip_forward` into a file for an audit report, and the file must contain only the bare value — no key name, no `=` sign. Which command gives you exactly that?
*   **A)** `sysctl net.ipv4.ip_forward > /opt/course/1/ip_forward`
*   **B)** `sysctl -n net.ipv4.ip_forward > /opt/course/1/ip_forward`
*   **C)** `sysctl -w net.ipv4.ip_forward > /opt/course/1/ip_forward`
*   **D)** `cat /etc/sysctl.conf | grep ip_forward > /opt/course/1/ip_forward`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** The `-n` flag tells `sysctl` to suppress the `key = value` label and print only the bare value, which is exactly what a script-friendly audit file needs.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because plain `sysctl <key>` prints the full `net.ipv4.ip_forward = 0` labeled line.
    *   *Option C* is incorrect because `-w` is the **write** flag — it requires a value to set (`key=value`) and modifies live kernel state rather than reading it.
    *   *Option D* is incorrect because it reads whatever is written in the persistent config file, not the kernel's actual live, in-memory value — the two can disagree if someone ran `sysctl -w` earlier without persisting it.
</details>

---

### Question 2
A batch job on a busy host suddenly starts failing with `fork: retry: Resource temporarily unavailable`, even though `top` and `free -m` show plenty of spare CPU and memory. You confirm the ceiling being hit is `kernel.pid_max`. After raising it live with `sysctl -w kernel.pid_max=4194304`, is the fix complete?
*   **A)** Yes — `sysctl -w` writes directly to the kernel, so the fix is permanent and complete.
*   **B)** No — the change is live-only and will revert on reboot unless it's also written into a file under `/etc/sysctl.d/` and reloaded with `sysctl --system`; the workload user's `ulimit -u` and any systemd `TasksMax=` ceiling should also be checked independently.
*   **C)** No — `pid_max` cannot be changed at runtime at all; it requires a kernel recompile.
*   **D)** Yes, and no other ceiling could possibly still be capping the same workload once `pid_max` is raised.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `sysctl -w` only pokes the live in-memory value — it reverts to whatever `/etc/sysctl.d/*.conf` says on the next reboot unless persisted there and reloaded. Separately, `pid_max` is one of *three independent* ceilings — a per-user `ulimit -u` or a systemd unit's `TasksMax=` can each independently cap the same fork-heavy workload even after `pid_max` is raised.
*   **Why others are incorrect:**
    *   *Option A* is incorrect — `sysctl -w` is explicitly the non-persistent half of the fix.
    *   *Option C* is incorrect — `pid_max` is a genuine runtime-tunable `/proc/sys` value, no recompile needed.
    *   *Option D* is incorrect — exactly the trap the scenario is testing: three independent ceilings can each cap the same workload, and fixing one doesn't guarantee the others aren't also binding.
</details>

---

### Question 3
You need the `pcspkr` kernel module to never load again on this host, even though the hardware it drives would normally cause the kernel to auto-detect and load it on every boot. Simply running `sudo rmmod pcspkr` right now would:
*   **A)** Permanently prevent it from ever loading again, including after a reboot.
*   **B)** Only unload it from the currently running kernel; it will very likely be auto-loaded again on the next boot or hardware re-detection unless it's also blacklisted in a file under `/etc/modprobe.d/`.
*   **C)** Corrupt the module's on-disk `.ko` file, permanently disabling it.
*   **D)** Require the module to first be blacklisted before it can be unloaded at all.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `rmmod` only affects the module's currently-loaded state in the running kernel. To stop the kernel from auto-loading it again on future boots or hardware re-detection passes, you must add a `blacklist pcspkr` line to a file under `/etc/modprobe.d/`.
*   **Why others are incorrect:**
    *   *Option A* is incorrect — that persistence requires the separate blacklist step.
    *   *Option C* is incorrect — `rmmod` never touches the on-disk module file.
    *   *Option D* is incorrect — `rmmod` and blacklisting are independent actions; neither is a prerequisite for the other.
</details>

---

### Question 4
A backup script hardcodes `/dev/sdb1` for an external USB drive, but the device letter keeps shifting whenever a second USB drive is temporarily attached. What is the correct, permanent fix?
*   **A)** Edit the script to always sleep 10 seconds before running, hoping device enumeration settles down.
*   **B)** Create a udev rule matching a stable hardware attribute of the drive (like `ATTRS{serial}`) that creates a persistent symlink such as `/dev/backup-drive`, then update the script to reference that symlink instead of the raw device letter.
*   **C)** Physically label the USB port so the same port is always used.
*   **D)** Use `fdisk -l` immediately before every backup run to look up whatever letter it currently has.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** Kernel-assigned device letters (`sdb`, `sdc`, ...) are assigned by discovery order, which is inherently unstable. A udev rule keyed on a stable hardware attribute like the drive's serial number creates a persistent, human-readable symlink that always points to the correct physical drive regardless of enumeration order.
*   **Why others are incorrect:**
    *   *Option A* is incorrect — timing hacks don't fix a fundamentally unstable identifier and are unreliable.
    *   *Option C* is incorrect — Linux doesn't guarantee a fixed device letter per physical port by default.
    *   *Option D* is incorrect — this works but requires manual intervention every run instead of a permanent, scriptable fix.
</details>

---

### Question 5
A per-user cronjob you just added with `crontab -e` as user `asset-manager` doesn't seem to run, but a nearly identical line already exists in `/etc/cron.d/legacy-job` naming `asset-manager` as the run-as user. What's the most likely underlying issue and correct fix?
*   **A)** Per-user crontabs are disabled by default and must be enabled in `sshd_config` first.
*   **B)** Nothing is wrong — cron will simply run the job twice, which is expected and harmless.
*   **C)** The job is likely running fine from *both* sources — the fix is to remove it from the system-wide `/etc/cron.d/` source once it's confirmed present in the per-user crontab, so it doesn't fire twice under two different scheduling mechanisms.
*   **D)** `crontab -e` edits require a reboot to take effect.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: C**

*   **Why C is correct:** System-wide cron sources (`/etc/cron.d/`, `/etc/crontab`) and per-user crontabs (`crontab -e`) are two independent scheduling mechanisms. Having the same logical job defined in both silently causes it to fire twice. Migrating a job means removing it from the old source once it's confirmed live in the new one.
*   **Why others are incorrect:**
    *   *Option A* is incorrect — per-user crontabs work independently of SSH configuration.
    *   *Option B* is incorrect — running a job twice is a real bug, not expected/harmless behavior, especially for anything non-idempotent.
    *   *Option D* is incorrect — `cron` picks up crontab changes automatically; no reboot or service restart is needed.
</details>

---

### Question 6
You need to extract just the IP address of a running Docker container named `frontend_v2` for an audit report, in a single command with no manual JSON parsing. Which is correct?
*   **A)** `docker ps | grep frontend_v2 | awk '{print $NF}'`
*   **B)** `docker inspect --format '{{.NetworkSettings.IPAddress}}' frontend_v2`
*   **C)** `docker logs frontend_v2 | grep -i "ip address"`
*   **D)** `docker exec frontend_v2 cat /etc/hosts | tail -1`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `docker inspect --format` with a Go template lets you pull one exact field out of a container's full metadata JSON precisely and reliably, without eyeballing or manually parsing raw output.
*   **Why others are incorrect:**
    *   *Option A* is incorrect — `docker ps` output doesn't include the container's IP address at all.
    *   *Option C* is incorrect — container logs are application output, not guaranteed to mention the container's own IP.
    *   *Option D* is incorrect — `/etc/hosts` inside the container is not a reliable source for the container's own externally-visible IP.
</details>

---

### Question 7
You're compiling `links2` from source and need to know which flag disables IPv6 support and where to install the resulting binary. What's the fastest, most reliable way to find both?
*   **A)** Guess based on flag names used by similar tools you've seen before.
*   **B)** Run `./configure --help` inside the extracted source directory and read the project's own documented flags directly.
*   **C)** Search a random internet forum for the exact command someone else used for a different version.
*   **D)** Skip `configure` entirely and edit the `Makefile` by hand to remove IPv6-related object files.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** Every well-formed autotools-based source project documents its own install-location and feature-toggle flags via `./configure --help`. This is the authoritative, version-correct source — exactly matching how the real LFCS exam expects you to work without internet access.
*   **Why others are incorrect:**
    *   *Option A* is incorrect — flag names and semantics vary project to project; guessing risks silently misconfiguring the build.
    *   *Option C* is incorrect — forum answers may target a different version or platform and aren't authoritative.
    *   *Option D* is incorrect — hand-editing a generated Makefile is fragile and bypasses the project's actual supported configuration mechanism.
</details>

---

### Question 8
You run `virsh shutdown inventory-db` on a persistent libvirt domain, but the domain doesn't stop after several minutes. What's happening, and what's the correct next step if this is a genuine emergency?
*   **A)** `virsh shutdown` sends an ACPI power-button signal that the guest OS can ignore or delay if it's busy or hung; if you need it stopped immediately, use `virsh destroy` for an unconditional, hard power-off.
*   **B)** The domain is transient, not persistent, so `shutdown` silently does nothing.
*   **C)** `virsh shutdown` always takes exactly 5 minutes by design; just wait longer.
*   **D)** `virsh shutdown` only works on domains that are already stopped.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: A**

*   **Why A is correct:** `virsh shutdown` is a graceful, ACPI-based request — exactly like pressing a physical power button — which a hung or busy guest OS can fail to honor. `virsh destroy`, despite its alarming name, is the hard, unconditional power-off equivalent of pulling the power cord, appropriate when a graceful shutdown isn't responding.
*   **Why others are incorrect:**
    *   *Option B* is incorrect — a persistent domain (defined with `virsh define`) fully supports `shutdown`; being transient vs. persistent affects whether the domain definition survives being stopped, not whether shutdown signals work.
    *   *Option C* is incorrect — there's no fixed timer; it depends entirely on the guest OS's own shutdown sequence.
    *   *Option D* is incorrect — `shutdown` is meant to be run against a currently-running domain.
</details>

---

### Question 9
An AppArmor-confined service was reconfigured to write logs to `/srv/applogs` instead of its default location. Standard Unix ownership and permissions on `/srv/applogs` are already correct, but the service still can't write there. What's the correct diagnostic and fix sequence?
*   **A)** Since DAC permissions are correct, the problem must be elsewhere (e.g. SELinux); AppArmor isn't relevant on Ubuntu.
*   **B)** Immediately run `aa-complain` on the profile to unblock the service — this is the fastest and fully sufficient permanent fix.
*   **C)** Check for a DENIED entry in the audit log (`journalctl -k` / `dmesg`), close the gap by adding the correct path rule to the service's AppArmor profile (hand-edit or via `aa-logprof`), reload the profile, and confirm it's back in **enforce** mode — not left in complain mode.
*   **D)** Delete the AppArmor profile file entirely so the service is never confined again.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: C**

*   **Why C is correct:** This is the "double gate" pattern: DAC and MAC are independent gates, and both must allow an action. The correct fix diagnoses the specific denial from the audit trail, closes exactly that gap in the profile, and confirms enforcement is genuinely restored — not bypassed.
*   **Why others are incorrect:**
    *   *Option A* is incorrect — AppArmor is Ubuntu's actively-enforcing, real, kernel-level MAC system; correct DAC permissions don't rule it out.
    *   *Option B* is incorrect — `complain` mode logs violations but no longer blocks them, which "fixes" the symptom by disabling protection rather than correctly scoping it; it should only be a temporary diagnostic step before returning to `enforce`.
    *   *Option D* is incorrect — removing confinement entirely is a security regression, not a fix.
</details>

---

### Question 10
On a RHEL-family host running SELinux in enforcing mode, you use `chcon` to fix a mislabeled file so a service can read it again. The fix works immediately — but a colleague warns you it won't survive a filesystem relabel. Why, and what's the correct persistent alternative?
*   **A)** `chcon` changes are always permanent; the colleague is mistaken.
*   **B)** `chcon` only edits the file's live security context directly, without updating SELinux's policy database — a relabel (`restorecon`, or a full `/.autorelabel`) restores the context based on policy, wiping out the manual `chcon` change. The persistent fix is `semanage fcontext` to add a policy rule, followed by `restorecon` to apply it.
*   **C)** The colleague means you must run `setenforce 0` permanently to avoid the problem.
*   **D)** `chcon` and `semanage fcontext` are exactly equivalent; either works identically for persistence.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `chcon` is a direct, one-off context edit that SELinux's policy database knows nothing about. `restorecon` (run during a relabel or on its own) resets contexts back to whatever the *policy* says they should be, silently reverting an unregistered `chcon` change. `semanage fcontext` registers the new expected context in policy itself, so `restorecon` reapplies (rather than reverts) it.
*   **Why others are incorrect:**
    *   *Option A* is incorrect — this is exactly the failure mode being tested.
    *   *Option C* is incorrect — disabling enforcement is a security regression, not a fix for context persistence.
    *   *Option D* is incorrect — only `semanage fcontext` writes to the policy database that `restorecon` reads from.
</details>

---

### Question 11
You need to add a vendor's third-party APT repository and are being careful to follow the current, non-deprecated key-trust approach. Which method is correct?
*   **A)** `sudo apt-key add vendor-key.gpg`
*   **B)** Download the vendor's GPG key into `/etc/apt/keyrings/`, then reference it explicitly with a `signed-by=/etc/apt/keyrings/vendor.gpg` option in the repository's `.list` (or `.sources`) entry.
*   **C)** Add the repository line with no key at all and pass `--allow-unauthenticated` to every future `apt install`.
*   **D)** Copy the vendor's key directly into `/etc/apt/trusted.gpg` without any reference in the repo entry.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `apt-key` is deprecated because it trusts a key for *every* repository system-wide. The modern approach scopes trust per-repository: the key lives in `/etc/apt/keyrings/`, and the repository's own source entry explicitly references it via `signed-by=`, so it only authenticates that one repository.
*   **Why others are incorrect:**
    *   *Option A* is incorrect — this is the deprecated, overly-broad trust mechanism.
    *   *Option C* is incorrect — this disables authentication entirely, a real security risk.
    *   *Option D* is incorrect — `/etc/apt/trusted.gpg` is also part of the deprecated global-trust mechanism, and without a `signed-by` reference the scoping benefit is lost anyway.
</details>

---

### Question 12
A colleague's `dpkg -i` of an unrelated package was interrupted mid-install, leaving the package in a half-configured state and `apt`/`dpkg` refusing further actions. What's the correct recovery sequence?
*   **A)** `sudo rm -rf /var/lib/dpkg/status` to reset the package database from scratch.
*   **B)** `sudo dpkg --configure -a` to resume any interrupted package configurations, followed by `sudo apt --fix-broken install` if dependency issues remain.
*   **C)** Reinstall the operating system.
*   **D)** `sudo apt purge --force-all` on every installed package to start clean.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `dpkg --configure -a` specifically resumes any package left in a half-configured state from an interrupted install. If that surfaces unmet dependencies, `apt --fix-broken install` (`apt-get -f install`) resolves them. This is the standard, safe recovery path.
*   **Why others are incorrect:**
    *   *Option A* is incorrect — deleting the dpkg status database destroys the record of every installed package on the system, an extremely destructive overreaction.
    *   *Option C* is incorrect — wildly disproportionate to a routine, well-documented recovery scenario.
    *   *Option D* is incorrect — purging every package would remove software that isn't actually broken.
</details>

---

### Question 13
You need to remove the `ftp` package so thoroughly that a future reinstall would start from a genuinely clean state — no leftover configuration files, and no orphaned dependencies that only `ftp` needed. Which command accomplishes this correctly?
*   **A)** `sudo apt remove ftp`
*   **B)** `sudo apt purge ftp && sudo apt autoremove`
*   **C)** `sudo rm -rf /usr/bin/ftp`
*   **D)** `sudo dpkg -r ftp`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `apt remove` alone leaves configuration files under `/etc` behind. `apt purge` removes the package's config files too. `apt autoremove` afterward cleans up any dependency packages that were pulled in only for `ftp` and are no longer needed by anything else.
*   **Why others are incorrect:**
    *   *Option A* is incorrect — `remove` leaves `/etc` config files in place, failing the "genuinely clean state" requirement.
    *   *Option C* is incorrect — manually deleting one binary file leaves the package still registered in dpkg's database, along with all its other files and orphaned dependencies.
    *   *Option D* is incorrect — equivalent to `apt remove`, not `purge`; config files remain, and no dependency cleanup happens.
</details>

---

### Question 14
You've been handed a standalone `.rpm` file for an internal tool. Before installing it, you need to see its declared version, dependencies, and full file list — without installing anything yet. Which commands do that?
*   **A)** `sudo rpm -i package.rpm` followed by `rpm -ql package-name`
*   **B)** `rpm -qip package.rpm` for metadata, and `rpm -qlp package.rpm` for the file list
*   **C)** `unzip package.rpm` to inspect its contents directly
*   **D)** `dnf install --assumeno package.rpm`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** The `-p` flag tells `rpm` to query an uninstalled package *file* directly rather than the installed-package database. `-qip` shows metadata (version, vendor, dependencies); `-qlp` lists every file the package would place on disk — both entirely without installing.
*   **Why others are incorrect:**
    *   *Option A* is incorrect — this installs the package first, which is exactly what the scenario says not to do yet.
    *   *Option C* is incorrect — RPM is not a zip archive; this won't produce meaningful package metadata.
    *   *Option D* is incorrect — even with `--assumeno`, this is a needlessly roundabout and less precise way to get the same information `rpm -qip`/`-qlp` give directly.
</details>

---

### Question 15
On a Rocky Linux host, `rpm -qa` errors out partway through instead of listing installed packages, and `dnf` fails at the transaction-check stage with a database-related error — even though every already-installed package's files on disk are untouched. What's the correct diagnosis and fix?
*   **A)** This is a dependency conflict; run `dnf install --skip-broken` to work around it.
*   **B)** This is RPM database corruption, not a package or disk-space problem; back up `/var/lib/rpm` before touching anything, then rebuild the database (e.g. `rpm --rebuilddb`), and verify the system is queryable again afterward.
*   **C)** This means the disk is out of space; run `dnf clean all` to free space.
*   **D)** Reinstall every package currently shown by `rpm -qa` to force-repair the database.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** Errors specifically at the database-query/transaction-check stage, with intact on-disk package files, point to RPM database corruption rather than a package, dependency, or disk-space issue. The safe recovery is to back up the database first (in case rebuild doesn't fully resolve it), then rebuild it and confirm queries work cleanly afterward.
*   **Why others are incorrect:**
    *   *Option A* is incorrect — `--skip-broken` addresses dependency resolution conflicts, not a corrupted query database.
    *   *Option C* is incorrect — the scenario explicitly states files on disk are untouched/fine; nothing points to disk space.
    *   *Option D* is incorrect — you can't reliably `rpm -qa` a corrupted database in the first place to know what to reinstall, and this skips the actual root cause.
</details>

---

### Question 16
You need to install the real, repository-published "Development Tools" group on a Rocky Linux host, but first you want to see exactly which packages are mandatory versus merely default versus optional members — without installing anything yet. Which command shows that?
*   **A)** `dnf group install "Development Tools"`
*   **B)** `dnf group info "Development Tools"`
*   **C)** `dnf list installed | grep -i development`
*   **D)** `dnf search "Development Tools"`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `dnf group info <name>` shows a group's real membership broken down by mandatory, default, and optional package tiers, entirely read-only, letting you review before committing to an install.
*   **Why others are incorrect:**
    *   *Option A* is incorrect — this installs the group immediately, skipping the review step the scenario asks for.
    *   *Option C* is incorrect — this only shows what's currently installed, not the group's defined membership.
    *   *Option D* is incorrect — `dnf search` finds packages/groups by keyword; it doesn't show a specific group's membership tiers.
</details>

---

### Question 17
On an openSUSE host, your team's policy is conservative: apply only curated security patches during a maintenance window, not a full raw package update. Which command follows that policy correctly?
*   **A)** `sudo zypper update`
*   **B)** `sudo zypper patch`
*   **C)** `sudo zypper dup`
*   **D)** `sudo zypper install --force-resolution`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `zypper patch` applies only the curated, often security-focused patch stream — a distinctly SUSE concept layered on top of ordinary package version bumps. It intentionally leaves out routine version-bump updates that aren't part of an official patch.
*   **Why others are incorrect:**
    *   *Option A* is incorrect — `zypper update` applies raw package version updates, exactly what the conservative policy says to avoid.
    *   *Option C* is incorrect — `zypper dup` performs a full distribution-version upgrade, far more aggressive than a patch-only policy.
    *   *Option D* is incorrect — this forces dependency resolution on an explicit install, unrelated to applying curated patches.
</details>

---

### Question 18
You want to find out which openSUSE package would provide the missing `/usr/sbin/ip` command, without installing anything yet. Which zypper command answers that directly?
*   **A)** `zypper search ip`
*   **B)** `zypper what-provides /usr/sbin/ip`
*   **C)** `zypper install /usr/sbin/ip`
*   **D)** `find / -name ip 2>/dev/null`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `zypper what-provides <path>` is purpose-built to resolve a specific file path back to the package that would provide it, entirely read-only.
*   **Why others are incorrect:**
    *   *Option A* is incorrect — a keyword search on "ip" would return a noisy, imprecise list of loosely-related package names, not a direct file-to-package resolution.
    *   *Option C* is incorrect — passing a file path to `zypper install` doesn't do a provider lookup, and would attempt an install rather than research.
    *   *Option D* is incorrect — `find` only locates a file that already exists on this system; it can't tell you which package would provide a *missing* file.
</details>

---

### Question 19
This lab platform's harness can only grade a VM by SSHing into it — it can't script an interactive GRUB rescue prompt or a genuinely unreachable machine. A lab teaches root filesystem repair via `chroot` by safely re-staging the scenario onto a disposable secondary disk. Inside that chroot, after fixing a bad `/etc/fstab` entry, what's the correct way to prove the fix works before ever rebooting?
*   **A)** Reboot the primary VM immediately and see if it comes back up.
*   **B)** Run `mount -a` inside the chroot — if it completes without error, the fstab entry is now syntactically and referentially correct.
*   **C)** Just re-read the fstab file visually; if it looks right, that's sufficient proof.
*   **D)** Run `fsck` on the mounted root filesystem from inside the chroot.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `mount -a` inside the chroot attempts to mount every entry in that filesystem's own `/etc/fstab` exactly as the real boot sequence would, so a clean, error-free run is direct proof the fix works — without ever needing to actually reboot the machine to find out.
*   **Why others are incorrect:**
    *   *Option A* is incorrect — on the real primary VM this risks losing SSH reachability if the fix is wrong, exactly what the safe re-staging approach is designed to avoid.
    *   *Option C* is incorrect — a visual read can miss a wrong UUID or device identifier that only fails at actual mount time.
    *   *Option D* is incorrect — `fsck` checks filesystem integrity, not whether an fstab entry is correctly formed and resolvable.
</details>

---

### Question 20
You need to back up a secondary GPT disk's partition table before doing risky repartitioning work on it, so a mistake can be undone without reconstructing partitions from memory. Which command creates that backup correctly?
*   **A)** `sudo dd if=/dev/vdc of=backup.img bs=4M`
*   **B)** `sudo sgdisk --backup=/root/vdc-table.bin /dev/vdc`
*   **C)** `sudo cp /dev/vdc /root/vdc-backup`
*   **D)** `sudo fdisk -l /dev/vdc > /root/vdc-table.txt`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `sgdisk --backup=<file> <disk>` writes a compact, purpose-built binary snapshot of exactly the GPT partition table structure, which can later be restored precisely with `sgdisk --load-backup`.
*   **Why others are incorrect:**
    *   *Option A* is incorrect — `dd`-ing the entire disk backs up all data too, which is far heavier than a partition-table-only backup and not what `sgdisk --load-backup` expects as input.
    *   *Option C* is incorrect — `cp` on a block device doesn't meaningfully copy a live disk's structure the way a proper backup tool does, and isn't restorable via `sgdisk`.
    *   *Option D* is incorrect — `fdisk -l` output is human-readable text, not a structured, restorable backup format.
</details>

---

## Audit and Review Key

Check your score and use this review matrix to trace any incorrect answers back to their exact section and module chapters:

| Question | Targeted Operations Competency | Review Chapter |
| :--- | :--- | :--- |
| **Q1** | Reading live kernel state with bare-value `sysctl -n` | **[Section 010, Module 01](./section-010/module-01/course.md)** |
| **Q2** | Diagnosing and persisting the three independent process/thread ceilings | **[Section 010, Module 02](./section-010/module-02/course.md)** |
| **Q3** | Kernel module unload vs. permanent blacklist | **[Section 010, Module 03](./section-010/module-03/course.md)** |
| **Q4** | Stable device naming with udev rules | **[Section 010, Module 04](./section-010/module-04/course.md)** |
| **Q5** | Per-user vs. system-wide cron migration | **[Section 020, Module 01](./section-020/module-01/course.md)** |
| **Q6** | Docker metadata extraction with `inspect --format` | **[Section 020, Module 02](./section-020/module-02/course.md)** |
| **Q7** | Discovering source-build flags via `./configure --help` | **[Section 030, Module 01](./section-030/module-01/course.md)** |
| **Q8** | Graceful vs. hard libvirt domain shutdown | **[Section 030, Module 02](./section-030/module-02/course.md)** |
| **Q9** | AppArmor denial diagnosis and enforce-mode repair | **[Section 040, Module 01](./section-040/module-01/course.md)** |
| **Q10** | SELinux persistent context fixes (`semanage fcontext` vs. `chcon`) | **[Section 040, Module 01](./section-040/module-01/course.md)** |
| **Q11** | Modern `signed-by` third-party APT repository trust | **[Section 050, Module 01](./section-050/module-01/course.md)** |
| **Q12** | Recovering a half-configured dpkg package state | **[Section 050, Module 02](./section-050/module-02/course.md)** |
| **Q13** | `apt purge` + `autoremove` for a genuinely clean removal | **[Section 050, Module 03](./section-050/module-03/course.md)** |
| **Q14** | Querying an uninstalled `.rpm` file's metadata and file list | **[Section 060, Module 01](./section-060/module-01/course.md)** |
| **Q15** | Diagnosing and rebuilding a corrupted RPM database | **[Section 060, Module 02](./section-060/module-02/course.md)** |
| **Q16** | Inspecting a dnf package group's real membership tiers | **[Section 060, Module 05](./section-060/module-05/course.md)** |
| **Q17** | The zypper patch-vs-update distinction | **[Section 070, Module 01](./section-070/module-01/course.md)** |
| **Q18** | Resolving a missing file to its providing package with `what-provides` | **[Section 070, Module 02](./section-070/module-02/course.md)** |
| **Q19** | Proving a chroot-based fstab repair with `mount -a` | **[Section 080, Module 01](./section-080/module-01/course.md)** |
| **Q20** | Backing up a GPT partition table with `sgdisk` | **[Section 080, Module 03](./section-080/module-03/course.md)** |
