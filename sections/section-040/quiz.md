# Section 040 Knowledge Check: Mandatory Access Control — SELinux & AppArmor

Test your understanding of the DAC-vs-MAC "double gate" model, AppArmor's path-based profiles and audit trail, and SELinux's label-based context system and persistent fix pattern.

---

## Scenario-Based Questions

### Question 1
On an Ubuntu 24.04 host, a service was reconfigured to write its logs to `/srv/applogs` instead of its original directory. `ls -l /srv/applogs` shows correct ownership and mode bits for the service's user, but every write attempt still fails. What is the single most useful next command to run to determine whether this is a Mandatory Access Control problem?
*   **A)** `chmod -R 777 /srv/applogs` to rule out permissions entirely.
*   **B)** `sudo aa-status`, to check whether AppArmor is active and which mode the service's profile is running in.
*   **C)** `sudo systemctl restart apparmor.service` to reset all profiles at once.
*   **D)** `sudo chown -R root:root /srv/applogs` to eliminate ownership as a variable.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** Correct DAC permissions plus a still-failing write, on an Ubuntu-family host, is the canonical signature of an AppArmor (MAC) denial rather than a DAC problem. `aa-status` reports whether AppArmor is loaded and enforcing at all, which profiles exist, and — critically — each profile's current mode, giving you the exact next fact needed to keep diagnosing.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because the scenario already states permissions are correct; loosening them further does nothing if the actual blocker is a MAC policy gap, and would also weaken security for no diagnostic benefit.
    *   *Option C* is incorrect because restarting the whole `apparmor` service is a blunt, unnecessary action that doesn't target the actual profile in question and isn't a diagnostic step at all.
    *   *Option D* is incorrect for the same reason as A — ownership was already stated to be correct, so changing it again provides no new information.
</details>

---

### Question 2
You run `sudo journalctl -k | grep 'apparmor="DENIED"'` and see the following line:
```
apparmor="DENIED" operation="open" profile="/usr/sbin/appservice" name="/srv/applogs/app.log" pid=1234 comm="appservice" requested_mask="w" denied_mask="w"
```
Which field tells you the exact filesystem path that needs a new permitting rule added to the profile?
*   **A)** `profile="/usr/sbin/appservice"`
*   **B)** `operation="open"`
*   **C)** `name="/srv/applogs/app.log"`
*   **D)** `pid=1234`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: C**

*   **Why C is correct:** AppArmor matches literal filesystem paths against rules written directly into a program's profile — there is no label involved anywhere. The `name=` field is that literal path, and it is exactly the string that must appear, correctly permitted, inside the profile before this operation will succeed.
*   **Why others are incorrect:**
    *   *Option A* identifies which profile did the denying (useful for knowing which file under `/etc/apparmor.d/` to edit) but is not itself the path needing a new rule.
    *   *Option B* tells you what kind of access was attempted (`open` for writing, per `requested_mask="w"`), not which path.
    *   *Option D* is just the process ID of the denied process — useful for correlating with `ps`, but irrelevant to writing the fix.
</details>

---

### Question 3
After editing `/etc/apparmor.d/usr.sbin.appservice` to add a rule permitting `/srv/applogs/*.log rw,`, the service still fails to write to that path. What is the most likely explanation?
*   **A)** AppArmor profiles cannot ever grant access to paths outside `/var/log/`.
*   **B)** The profile edit was never reloaded into the running kernel with `apparmor_parser -r`, so the kernel is still enforcing the old version of the profile.
*   **C)** The rule needs a trailing `capability` line to take effect.
*   **D)** AppArmor requires a full system reboot after every profile edit.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** Editing a profile *file* on disk has zero effect on the kernel's active policy until that profile is explicitly reparsed and reloaded with `apparmor_parser -r <profile-path>`. This is the AppArmor equivalent of forgetting `systemctl daemon-reload` after editing a unit file — a very common, easy-to-miss step that produces exactly this "my fix didn't work" symptom.
*   **Why others are incorrect:**
    *   *Option A* is false; AppArmor path rules can grant access to any path an administrator writes a rule for.
    *   *Option C* is incorrect because `capability` lines grant Linux capabilities, an entirely separate rule type from path rules, and are not required for a plain file read/write.
    *   *Option D* is incorrect — `apparmor_parser -r` reloads a single profile live, with no reboot needed.
</details>

---

### Question 4
An administrator fixes an SELinux-caused `403 Forbidden` on a relocated web content directory by running `sudo chcon -t httpd_sys_content_t /srv/webdata/index.html` and confirms the page now loads. Weeks later, after an unrelated system update triggers a filesystem relabel, the exact same `403 Forbidden` reappears with no further changes made. What went wrong?
*   **A)** `chcon` only edits a file's live context directly, with no corresponding entry in SELinux's persistent file-context database — a relabel event reverts the file to whatever that database says, silently undoing the fix.
*   **B)** `chcon` is a read-only diagnostic command and was never capable of changing anything in the first place.
*   **C)** The web server's DAC permissions expired after 30 days by default.
*   **D)** SELinux automatically disables itself after any system update.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: A**

*   **Why A is correct:** `chcon` changes a file's on-disk extended-attribute label immediately, but that change lives nowhere else — there is no matching rule in the persistent file-context database backing `/etc/selinux/<policy>/contexts/files/file_contexts.local`. A relabel event (policy update, `restorecon -R /`, etc.) reapplies the database's ruling, which was never updated, silently reverting the file to its original, incorrect type. The persistent fix is `semanage fcontext -a` (which writes the database rule) followed by `restorecon` (which applies it) — a combination that survives any number of future relabels.
*   **Why others are incorrect:**
    *   *Option B* is false — `chcon` genuinely does change a file's context immediately; the problem is durability, not effect.
    *   *Option C* is incorrect; DAC permissions have no expiration mechanism, and the scenario states nothing about them changing.
    *   *Option D* is incorrect; SELinux does not disable itself on update — it was still `Enforcing` the whole time, correctly applying its (unpatched) database ruling.
</details>

---

### Question 5
A web server needs to bind a new, non-default TCP port, `8443`, on an SELinux `Enforcing` host. Which statement correctly describes what's required?
*   **A)** Nothing extra is needed — SELinux only governs file access, never network ports.
*   **B)** Adding `listen 8443;` to the web server's own configuration file is sufficient on its own.
*   **C)** The port must be added to an SELinux-approved port type (e.g. `semanage port -a -t http_port_t -p tcp 8443`) *in addition to* the web server's own config change — file context and port-type policy are two entirely separate SELinux mechanisms, and a config change alone doesn't satisfy either.
*   **D)** Binding a new port always requires switching SELinux to `Permissive` mode first.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: C**

*   **Why C is correct:** Port binding is governed by a distinct SELinux object class (port types), completely separate from file-context policy. A confined process domain may only bind ports whose SELinux port type it has policy trust for; `semanage port -l | grep http_port_t` shows what's already covered, and `semanage port -a` extends that set. This is independent of, and required in addition to, the web server's own `listen` directive — SELinux permitting a bind doesn't make the server attempt one, and the server attempting one doesn't mean policy allows it.
*   **Why others are incorrect:**
    *   *Option A* is false — SELinux mediates network port binds via port-type policy, a real and commonly-tested mechanism.
    *   *Option B* is incomplete — the config change alone says nothing to SELinux's policy; without the port-type grant, the bind can fail or generate an AVC denial depending on policy version.
    *   *Option D* is incorrect and would be a serious security regression — switching to `Permissive` disables enforcement system-wide as a "fix," which is never the correct approach for a specific, narrow port-policy gap.
</details>
