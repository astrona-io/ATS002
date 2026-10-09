# Section 030 Knowledge Check: Building & Virtualizing Systems

Astronaut, test your understanding of source builds, finding `configure` flags, and the libvirt domain lifecycle: persistent and transient domains, autostart, and graceful versus hard shutdown.

---

## Scenario-Based Questions

Each question describes a real situation from the exam topics. Pick your answer before you open the explanation.

### Question 1
You have been handed `monitor-agent-3.2.tar.bz2` and need to unpack it before building. You run `tar xzf monitor-agent-3.2.tar.bz2`, and it fails at once with a decompression error. What is the most likely cause, and what should you run instead?
*   **A)** The tarball is corrupted and must be downloaded again; no `tar` flag combination will fix this.
*   **B)** You used `-z` (gzip) on a bzip2-compressed archive; the fix is `tar xjf monitor-agent-3.2.tar.bz2`, using `-j` for bzip2.
*   **C)** You forgot to run `chmod +x` on the tarball before extracting it.
*   **D)** `.tar.bz2` files can only be extracted with `unzip`, not `tar`.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** The `.tar.bz2` extension means bzip2 compression, which `tar` opens with the `-j` flag, not `-z` (which is for gzip's `.tar.gz` or `.tgz`). The wrong decompression flag does not produce a partial or garbled extract. It fails outright, because the gzip decompressor cannot read bzip2 data.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because a flag mismatch, not corruption, is by far the most common cause of this exact failure, and you should rule it out first.
    *   *Option C* is incorrect because the permissions on the archive file have nothing to do with whether `tar` can decompress it.
    *   *Option D* is incorrect because `tar` handles bzip2 archives itself with `-j`; `unzip` is for `.zip` archives only.
</details>

---

### Question 2
A task requires a binary built from source to land at the exact path `/opt/tools/bin/reportd`. You run `./configure --prefix=/opt/tools`, then `make` and `sudo make install`, but the binary ends up at `/opt/tools/bin/reportd-cli` instead, the project's own name for it. What should you have done differently?
*   **A)** Nothing — `--prefix` always guarantees an exact binary filename match; the task's requested name must be wrong.
*   **B)** Used `--bindir=/opt/tools/bin` instead of `--prefix`, which still would not have fixed the filename mismatch, since `--bindir` (like `--prefix`) only controls the install *directory*, not the binary's filename.
*   **C)** Skipped `./configure` entirely and just run `make install` with a `DESTDIR` override.
*   **D)** Renamed the source tarball itself to `reportd.tar.bz2` before extracting it.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `--prefix` sets the root of the whole install tree, and the binary lands at `$prefix/bin/<the-name-the-project-gives-its-output>`, which is not always the name a task wants. `--bindir` is more precise about *which folder* the binary goes into, but neither flag controls the *file name* that the project's `Makefile` installs. If the name still does not match after you use the right folder flag, the last step is an explicit rename (for example `sudo mv /opt/tools/bin/reportd-cli /opt/tools/bin/reportd`). Never assume the flags alone finish the job; check the installed file.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because `--prefix` never guarantees a file name, only a folder tree. The mismatch described is a normal, common result, not a mistake in the task.
    *   *Option C* is incorrect because without `./configure` there is no `Makefile` for `make install` to work from.
    *   *Option D* is incorrect because the name of the source tarball has no effect on what the project's build system calls its compiled output.
</details>

---

### Question 3
You need to define a KVM virtual machine that still appears in `virsh list --all` after a full host reboot and after the domain is powered off. Which command gives that result, and why does the other one not?
*   **A)** `virsh create domain.xml` — because `create` always writes a permanent record to `/etc/libvirt/qemu/`.
*   **B)** `virsh define domain.xml` — because `define` registers the XML persistently in libvirt's configuration store, while `virsh create` only starts a transient domain that vanishes entirely once it stops.
*   **C)** Either command works identically; persistence is a property of the qcow2 disk image, not the `virsh` subcommand used.
*   **D)** `virsh start domain.xml` — because `start` is the only subcommand that writes to `/etc/libvirt/qemu/`.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `virsh define` and `virsh create` accept the same XML, but they behave completely differently afterwards. `define` writes the domain's XML into libvirt's permanent store (the file `/etc/libvirt/qemu/<name>.xml`), so the domain shows up in `virsh list --all` for good, running or shut off, until someone runs `virsh undefine`. `virsh create` instead starts a *transient* domain that exists only in the libvirt daemon's memory while it runs. The moment it stops, for any reason, its definition is gone, and nothing is left to start again.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because it reverses the real behaviour: `create` is the transient one.
    *   *Option C* is incorrect because persistence depends only on how the domain was registered with libvirt, not on anything in the disk image.
    *   *Option D* is incorrect because `virsh start` does not take an XML file path like this. It starts an already defined domain by name.
</details>

---

### Question 4
After running `virsh autostart inventory-db` on one host, you copy that domain's `virsh dumpxml inventory-db` output to a second host and run `virsh define` there. After a reboot of the second host, the domain does not start by itself. What is the most likely explanation?
*   **A)** `dumpxml` output is corrupted during copy between hosts and must be hand-edited before reuse.
*   **B)** Autostart is tracked by libvirt as separate metadata (a symlink under `/etc/libvirt/qemu/autostart/`) rather than a field inside the portable domain XML, so it does not travel with a copied `dumpxml` file and must be re-enabled on the new host.
*   **C)** `virsh autostart` only applies to transient domains created with `virsh create`.
*   **D)** Autostart requires the domain to be actively running at the moment `dumpxml` is captured.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `virsh autostart` does not change the domain XML at all. It creates a symlink in `/etc/libvirt/qemu/autostart/` that points back at the domain's persistent definition. `dumpxml` prints only the portable XML, not libvirt's separate autostart link, so copying that XML to a new host and defining it there carries no autostart setting with it. You have to run `virsh autostart inventory-db` again on the second host.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because `dumpxml` output is plain, well-formed XML, and a normal copy does not corrupt it.
    *   *Option C* is incorrect because autostart applies to persistently defined domains. A transient domain has no persistent definition for the autostart symlink to point at.
    *   *Option D* is incorrect because the autostart setting does not depend on whether the domain was running when you saved its XML.
</details>

---

### Question 5
You run `virsh shutdown inventory-db`, then check `virsh list --all` two minutes later and see that the domain is still `running`. What is the most likely explanation, and what is the right next step?
*   **A)** `virsh shutdown` always takes at least five minutes; simply wait longer with no further action.
*   **B)** The guest operating system has no ACPI shutdown handling (or is hung) and never acted on the power-button signal; escalate with `virsh destroy inventory-db` for an immediate hard power-off.
*   **C)** `virsh shutdown` failed silently and must be retried with `sudo` even though the first attempt already used `sudo`.
*   **D)** The domain must be `virsh undefine`d before it will accept any shutdown signal.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `virsh shutdown` sends an ACPI (Advanced Configuration and Power Interface) power-button *event* into the guest. It is a polite request, not a command that forces anything. If the guest operating system has no handler for that event, or is hung, it never reacts, and the domain stays `running` for ever. The right escalation for a guest that does not respond is `virsh destroy`, which ends the underlying QEMU process at once, the software version of pulling the power cord, whatever is happening inside the guest.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because `shutdown` has no fixed minimum time. A cooperating guest usually powers off within seconds, and one that does not cooperate never will, however long you wait.
    *   *Option C* is incorrect because `sudo` has nothing to do with whether the *guest operating system* acts on an ACPI event it received.
    *   *Option D* is incorrect because `undefine` deletes the domain's persistent definition and does nothing to power off a running domain.
</details>
