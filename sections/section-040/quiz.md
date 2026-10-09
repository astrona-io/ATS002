# Section 040 Knowledge Check: Mandatory Access Control — SELinux & AppArmor

Test your understanding of the two gates: Discretionary Access Control (DAC, the owner's rwx bits) and Mandatory Access Control (MAC, the system-wide policy). The questions cover AppArmor's path-based profiles and its audit log, and SELinux's label-based contexts and its lasting fix.

---

## Scenario-Based Questions

Each question describes a real situation on a machine. Pick your answer before you open the explanation.

### Question 1
On an Ubuntu 24.04 machine, a service was set up to write its logs to `/srv/applogs` instead of its old folder. `ls -l /srv/applogs` shows the correct owner and mode bits for the service's user, but every write still fails. What is the single most useful next command to find out whether this is a Mandatory Access Control problem?
*   **A)** `chmod -R 777 /srv/applogs` to rule out permissions completely.
*   **B)** `sudo aa-status`, to check whether AppArmor is active and which mode the service's profile is in.
*   **C)** `sudo systemctl restart apparmor.service` to reset all profiles at once.
*   **D)** `sudo chown -R root:root /srv/applogs` to remove ownership as a cause.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** Correct DAC permissions plus a write that still fails, on an Ubuntu-family machine, is the classic sign of an AppArmor (MAC) denial rather than a DAC problem. `aa-status` reports whether AppArmor is loaded and enforcing at all, which profiles exist, and, most importantly, the current mode of each profile. That is exactly the next fact you need.
*   **Why the others are wrong:**
    *   *Option A* is wrong because the scenario already says the permissions are correct. Loosening them further does nothing if the real blocker is a missing MAC rule, and it weakens security for no gain.
    *   *Option C* is wrong because restarting the whole `apparmor` service is a blunt step that does not target the profile in question, and it tells you nothing.
    *   *Option D* is wrong for the same reason as A: the ownership is already correct, so changing it again gives you no new information.
</details>

---

### Question 2
You run `sudo journalctl -k | grep 'apparmor="DENIED"'` and see this line:
```
apparmor="DENIED" operation="open" profile="/usr/sbin/appservice" name="/srv/applogs/app.log" pid=1234 comm="appservice" requested_mask="w" denied_mask="w"
```
Which field tells you the exact filesystem path that needs a new rule in the profile?
*   **A)** `profile="/usr/sbin/appservice"`
*   **B)** `operation="open"`
*   **C)** `name="/srv/applogs/app.log"`
*   **D)** `pid=1234`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: C**

*   **Why C is correct:** AppArmor compares exact filesystem paths with the rules written in a program's profile. No label is involved anywhere. The `name=` field is that exact path, and it is the string that must appear, with the right access, in the profile before this action can succeed.
*   **Why the others are wrong:**
    *   *Option A* names the profile that said no. That tells you which file under `/etc/apparmor.d/` to edit, but it is not the path that needs a new rule.
    *   *Option B* tells you what kind of access was tried (`open`, for writing, as `requested_mask="w"` shows), not which path.
    *   *Option D* is only the process number of the denied process. It helps you match it with `ps`, but it plays no part in the fix.
</details>

---

### Question 3
You edited `/etc/apparmor.d/usr.sbin.appservice` and added the rule `/srv/applogs/*.log rw,`, but the service still cannot write to that path. What is the most likely explanation?
*   **A)** AppArmor profiles can never grant access to paths outside `/var/log/`.
*   **B)** The changed profile was never reloaded into the running kernel with `apparmor_parser -r`, so the kernel still enforces the old version.
*   **C)** The rule needs a `capability` line after it to take effect.
*   **D)** AppArmor needs a full reboot after every profile edit.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** Editing a profile *file* on disk has no effect on the kernel's active policy until you reload that profile with `apparmor_parser -r <profile-path>`. It is the AppArmor version of forgetting `systemctl daemon-reload` after editing a unit file: a common, easy-to-miss step that gives exactly this "my fix did not work" result.
*   **Why the others are wrong:**
    *   *Option A* is false. AppArmor path rules can grant access to any path an administrator writes a rule for.
    *   *Option C* is wrong because `capability` lines grant Linux capabilities, a completely different kind of rule. A plain file read or write does not need one.
    *   *Option D* is wrong. `apparmor_parser -r` reloads one profile while the system runs, with no reboot.
</details>

---

### Question 4
An administrator fixes an SELinux-caused `403 Forbidden` on a moved web content folder by running `sudo chcon -t httpd_sys_content_t /srv/webdata/index.html`, and the page now loads. Weeks later, an unrelated system update triggers a filesystem relabel, and the exact same `403 Forbidden` comes back with no other changes. What went wrong?
*   **A)** `chcon` only changes a file's live context, with no matching entry in SELinux's lasting file-context database. A relabel sets the file back to whatever that database says, which quietly undoes the fix.
*   **B)** `chcon` is a read-only diagnostic command and could never change anything.
*   **C)** The web server's DAC permissions expired after 30 days by default.
*   **D)** SELinux switches itself off after any system update.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: A**

*   **Why A is correct:** `chcon` changes the file's label on disk at once, but that change is stored nowhere else. There is no matching rule in the lasting file-context database behind `/etc/selinux/<policy>/contexts/files/file_contexts.local`. A relabel (a policy update, `restorecon -R /` and so on) applies the database again. The database was never updated, so the file quietly goes back to its old, wrong type. The lasting fix is `semanage fcontext -a` (which writes the database rule) followed by `restorecon` (which applies it). That pair survives any number of later relabels.
*   **Why the others are wrong:**
    *   *Option B* is false. `chcon` really does change a file's context at once; the problem is that the change does not last.
    *   *Option C* is wrong. DAC permissions never expire, and the scenario says nothing about them changing.
    *   *Option D* is wrong. SELinux does not switch itself off on an update. It stayed `Enforcing` the whole time and correctly applied its database, which nobody had fixed.
</details>

---

### Question 5
A web server must bind a new, non-default TCP port, `8443`, on an SELinux `Enforcing` machine. Which statement correctly describes what is needed?
*   **A)** Nothing extra: SELinux only controls file access, never network ports.
*   **B)** Adding `listen 8443;` to the web server's own configuration file is enough on its own.
*   **C)** The port must be in an SELinux port type the web server may use (for example `semanage port -a -t http_port_t -p tcp 8443`) *in addition to* the web server's own configuration change. File context and port-type policy are two separate SELinux mechanisms, and a configuration change alone does not satisfy SELinux.
*   **D)** Binding a new port always means switching SELinux to `Permissive` mode first.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: C**

*   **Why C is correct:** Port binding is controlled by its own kind of SELinux object (port types), separate from file-context policy. A confined process domain may only bind ports whose SELinux port type its policy allows. `semanage port -l | grep http_port_t` shows which ports are already covered, and `semanage port -a` adds to that set. This is separate from, and needed as well as, the web server's own `listen` setting: SELinux allowing a bind does not make the server try one, and the server trying one does not mean the policy allows it.
*   **A note on this port:** on a standard RHEL targeted policy, `8443` is usually already listed under `http_port_t`, and `semanage port -a` then fails with `Port tcp/8443 already defined`. Always check `semanage port -l` first, and add the port only if it is missing.
*   **Why the others are wrong:**
    *   *Option A* is false. SELinux controls network port binds through port-type policy, a real and often tested mechanism.
    *   *Option B* is incomplete. The configuration change alone tells SELinux's policy nothing. Without the port type, the bind can fail or produce an AVC denial, depending on the policy version.
    *   *Option D* is wrong and would seriously weaken security. Switching to `Permissive` turns off enforcement for the whole system as a "fix", which is never the right answer to one narrow port-policy gap.
</details>
