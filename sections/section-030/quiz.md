# Section 030 Knowledge Check: Building & Virtualizing Systems

Test your understanding of source-build pipelines, `configure` flag discovery, and libvirt domain lifecycle management — persistent vs. transient domains, autostart, and graceful vs. hard shutdown.

---

## Scenario-Based Questions

### Question 1
You've been handed `monitor-agent-3.2.tar.bz2` and need to unpack it before building. You run `tar xzf monitor-agent-3.2.tar.bz2` and it immediately fails with a decompression error. What is the most likely cause, and what should you run instead?
*   **A)** The tarball is corrupted and must be re-downloaded; no `tar` flag combination will fix this.
*   **B)** You used `-z` (gzip) against a bzip2-compressed archive; the fix is `tar xjf monitor-agent-3.2.tar.bz2`, using `-j` for bzip2.
*   **C)** You forgot to run `chmod +x` on the tarball before extracting it.
*   **D)** `.tar.bz2` files can only be extracted with `unzip`, not `tar`.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** The `.tar.bz2` extension signals bzip2 compression, which `tar` decompresses with the `-j` flag, not `-z` (which is for gzip's `.tar.gz`/`.tgz`). Passing the wrong decompression flag doesn't produce a partial or garbled extraction — it fails outright, because gzip's decompressor has no idea what to do with bzip2-format bytes.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because a flag mismatch, not corruption, is by far the most common cause of this exact failure mode, and should be ruled out first.
    *   *Option C* is incorrect because file permissions on the archive itself have no bearing on `tar`'s ability to decompress its contents.
    *   *Option D* is incorrect because `tar` natively handles bzip2 archives via `-j`; `unzip` is for `.zip` archives entirely.
</details>

---

### Question 2
A task requires a source-built binary to land at the exact path `/opt/tools/bin/reportd`. You run `./configure --prefix=/opt/tools` followed by `make` and `sudo make install`, but the binary ends up at `/opt/tools/bin/reportd-cli` instead — the project's own internal binary name. What should you have done differently?
*   **A)** Nothing — `--prefix` always guarantees an exact binary filename match; the task's requested name must be wrong.
*   **B)** Used `--bindir=/opt/tools/bin` instead of `--prefix`, which still would not have fixed the filename mismatch, since `--bindir` (like `--prefix`) only controls the install *directory*, not the binary's filename.
*   **C)** Skipped `./configure` entirely and just run `make install` with a `DESTDIR` override.
*   **D)** Renamed the source tarball itself to `reportd.tar.bz2` before extracting it.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `--prefix` sets the root of the entire install tree, and the binary lands at `$prefix/bin/<whatever-the-project-names-its-own-output>` — not necessarily the name a task wants. `--bindir` is more precise about *where* the binary directory is, but neither flag controls the *filename* the project's `Makefile` chooses to install as. If the installed name still doesn't match after using the correct directory flag, the closing step is an explicit rename (e.g. `sudo mv /opt/tools/bin/reportd-cli /opt/tools/bin/reportd`) — never assume the flags alone finish the job without verifying the final artifact.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because `--prefix` never guarantees a specific filename — only a directory tree — and the mismatch described is a completely expected, common outcome, not a bug in the task.
    *   *Option C* is incorrect because skipping `./configure` means there's no `Makefile` for `make install` to act on at all.
    *   *Option D* is incorrect because renaming the source tarball has no effect on what the project's own build system names its compiled output.
</details>

---

### Question 3
You need to define a KVM virtual machine that must still appear in `virsh list --all` even after a full host reboot and the domain being powered off. Which command produces that outcome, and why does the alternative fail to?
*   **A)** `virsh create domain.xml` — because `create` always writes a permanent record to `/etc/libvirt/qemu/`.
*   **B)** `virsh define domain.xml` — because `define` registers the XML persistently in libvirt's config store, while `virsh create` only starts a transient domain that vanishes entirely once it stops.
*   **C)** Either command works identically; persistence is a property of the qcow2 disk image, not the `virsh` subcommand used.
*   **D)** `virsh start domain.xml` — because `start` is the only subcommand that writes to `/etc/libvirt/qemu/`.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `virsh define` and `virsh create` both accept identical XML input, but they behave completely differently afterward. `define` writes the domain's XML into libvirt's permanent config store (visible under `/etc/libvirt/qemu/<name>.xml`), so it shows up in `virsh list --all` indefinitely — running or shut off — until explicitly `virsh undefine`d. `virsh create` instead starts a *transient* domain that exists only in libvirtd's memory for as long as it's running; the moment it stops, for any reason, the definition is gone completely, with nothing left to restart.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because it reverses the actual behavior — `create` is the transient one.
    *   *Option C* is incorrect because persistence is entirely a property of how the domain was registered with libvirt, not anything about the underlying disk image.
    *   *Option D* is incorrect because `virsh start` isn't even valid against a raw XML file path in this way — it starts an already-defined domain by name.
</details>

---

### Question 4
After running `virsh autostart inventory-db` on one host, you copy that domain's `virsh dumpxml inventory-db` output to a second host and `virsh define` it there. After rebooting the second host, the domain does not start automatically. What's the most likely explanation?
*   **A)** `dumpxml` output is corrupted during copy between hosts and must be hand-edited before reuse.
*   **B)** Autostart is tracked by libvirt as separate metadata (a symlink under `/etc/libvirt/qemu/autostart/`) rather than a field inside the portable domain XML, so it does not travel with a copied `dumpxml` file and must be re-enabled on the new host.
*   **C)** `virsh autostart` only applies to transient domains created with `virsh create`.
*   **D)** Autostart requires the domain to be actively running at the moment `dumpxml` is captured.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `virsh autostart` doesn't modify the domain XML at all — it creates a symlink in `/etc/libvirt/qemu/autostart/` pointing back at the domain's persistent definition. Since `dumpxml` only prints the portable XML, not libvirt's separate autostart bookkeeping, copying that XML to a new host and defining it there carries none of the original autostart configuration along. `virsh autostart inventory-db` has to be run again, explicitly, on the second host.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because `dumpxml` output is plain, well-formed XML with no corruption risk from a normal copy.
    *   *Option C* is incorrect because autostart applies to persistently defined domains — a transient domain has no persistent definition for the autostart symlink to reference in the first place.
    *   *Option D* is incorrect because autostart configuration has no dependency on the domain's running state at the time it's set.
</details>

---

### Question 5
You run `virsh shutdown inventory-db` against a guest, then check `virsh list --all` two minutes later and see it is still `running`. What is the most likely explanation, and what is the correct next step?
*   **A)** `virsh shutdown` always takes at least five minutes; simply wait longer with no further action.
*   **B)** The guest OS has no ACPI shutdown handling (or is hung) and never acted on the power-button signal; escalate with `virsh destroy inventory-db` for an immediate hard power-off.
*   **C)** `virsh shutdown` failed silently and must be retried with `sudo` even though the first attempt already used `sudo`.
*   **D)** The domain must be `virsh undefine`d before it will accept any shutdown signal.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `virsh shutdown` sends an ACPI power-button *event* into the guest — it is a polite request, not a command that forces anything. If the guest OS has no ACPI event handler configured, or is hung, it simply never reacts, and the domain sits at `running` indefinitely. The correct escalation for a guest that won't respond is `virsh destroy`, which immediately halts the underlying QEMU process — the software equivalent of pulling the power cord — regardless of what's happening inside the guest.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because `shutdown` has no fixed minimum duration; a cooperative guest typically powers off within seconds, and an uncooperative one never will, no matter how long you wait.
    *   *Option C* is incorrect because `sudo` privileges have no bearing on whether the *guest OS* chooses to act on an ACPI signal it received correctly.
    *   *Option D* is incorrect because `undefine` removes the domain's persistent definition entirely and has nothing to do with getting a running domain to power off.
</details>
