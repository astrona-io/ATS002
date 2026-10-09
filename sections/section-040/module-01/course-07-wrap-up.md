# Wrap-Up: Mission Debrief

Well flown, astronaut. You have met the ship's security chief in both of its forms: AppArmor, which checks paths, and SELinux, which checks labels. Before you move on, look back at what you learned, check yourself, and land the playground cleanly.

## What you learned

This module was about the second gate behind file permissions, and how to find and close a denial without switching that gate off.

**From [Two Gates: DAC, MAC And Which System You Are On](./course-01-two-gates-dac-mac-and-which-system.md):**

- DAC (the rwx bits, set by the owner) is checked first. MAC (a system-wide policy) is checked second. Both must allow the action.
- Both gates give the same "Permission denied". If `ls -l` allows the action and it still fails, look at MAC.
- AppArmor runs on Ubuntu, Debian and SUSE. SELinux runs on the RHEL family. `/sys/kernel/security/lsm` shows which one a machine uses.
- AppArmor matches paths; SELinux matches labels. Move a file and an AppArmor path rule stops matching, while an SELinux label moves with the file.

**From [AppArmor Profiles And Modes](./course-02-apparmor-profiles-and-modes.md):**

- `aa-status` shows whether AppArmor is loaded, which profiles are in enforce or complain mode, and which processes are held right now.
- Profiles live in `/etc/apparmor.d/`, named after the program with `/` turned into `.`. Your own rules go into the `local/` file.
- A path rule is `path mode,`, with modes such as `r`, `w`, `ix`, `px` and `rix`. A `capability` line is a different kind of rule.
- Enforce mode blocks and logs. Complain mode only logs. `aa-complain` and `aa-enforce` switch one profile.

**From [Read An AppArmor Denial](./course-03-apparmor-reading-a-denial.md):**

- AppArmor denials go to the kernel log. `journalctl -k | grep 'apparmor="DENIED"'` finds them, and they survive a ring-buffer wrap.
- `profile=` names the profile to change, `name=` the exact path, and `denied_mask=` the refused access.
- An AppArmor denial has no label in it. The path was the whole decision.

**From [Fix An AppArmor Denial And Prove It](./course-04-apparmor-fixing-a-denial.md):**

- Add the rule to `/etc/apparmor.d/local/<profile>`, or let `aa-logprof` suggest it.
- Load the change with `apparmor_parser -r` on the main profile. Without it, the kernel keeps the old profile.
- A real fix ends in enforce mode, with the action working and no new denials. Complain mode is not a fix.

**From [SELinux Labels And AVC Denials](./course-05-selinux-labels-and-avc-denials.md):**

- A context is `user:role:type:level`, and the `type` field drives the decisions. SELinux denies anything without an `allow` rule.
- `getenforce` shows Enforcing, Permissive or Disabled. `setenforce` only switches until the next reboot.
- `ls -Z` and `ps -eZ` show labels. `ausearch -m avc` shows denials, with `scontext` (the process) and `tcontext` (the object).

**From [Persistent SELinux Fixes And The AppArmor Contrast](./course-06-selinux-persistent-fixes-and-contrast.md):**

- `chcon` changes the live label only, and the next relabel undoes it.
- The lasting fix is `semanage fcontext -a` (writes the rule) and then `restorecon -Rv` (relabels the files).
- Ports are a separate table: check `semanage port -l` first, and add with `semanage port -a` only if the port is missing.

## Your missions

You proved the AppArmor skills in graded missions, right after the part that taught them:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [AppArmor Profile Enforcement Lab](./labs/lab-01/README.md) | Fix An AppArmor Denial And Prove It | find a write denial, add the rule, reload, and keep the profile enforcing |
| [AppArmor: Repair a Read Denial Lab](./labs/lab-02/README.md) | Fix An AppArmor Denial And Prove It | close a read denial the same way, with the profile still enforcing |

SELinux has no mission, because the Ubuntu training ship cannot run it. Practise its commands in your head with the worked example until you can say each step without looking.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. <code>ls -l</code> shows the service's user owns the folder with mode <code>750</code>, and its writes still fail. What do you check next?</summary>

MAC. Correct DAC plus a denial is the sign of the second gate. On Ubuntu, run `sudo aa-status` to see whether AppArmor is loaded and which mode the service's profile is in.
</details>

<details>
<summary>2. <code>aa-status</code> lists a profile. Does that mean it blocks anything?</summary>

Not on its own. Check which list it is in. A profile under "complain mode" is loaded and logs, but blocks nothing. Only a profile under "enforce mode" really holds the program in check.
</details>

<details>
<summary>3. Which two fields of an <code>apparmor="DENIED"</code> line tell you what to fix?</summary>

`profile=` names the profile to change, and `name=` is the exact path the new rule must match. `denied_mask=` then tells you which access to grant.
</details>

<details>
<summary>4. You added the right rule to the <code>local/</code> file, but the writes still fail. What did you forget?</summary>

Reloading the profile: `sudo apparmor_parser -r /etc/apparmor.d/<main profile>`. Editing the file only changes the text on disk; the kernel keeps the version it last loaded.
</details>

<details>
<summary>5. You switch a profile to complain mode and the error goes away. Is the problem fixed?</summary>

No. The action works because nothing is checked. The real fix is a rule for the path, a reload, and the profile back in enforce mode with the action still working.
</details>

<details>
<summary>6. On a RHEL machine, an AVC shows <code>scontext=...:httpd_t:s0</code> and <code>tcontext=...:var_t:s0</code>. What is wrong?</summary>

The file has the wrong type. The policy has no rule that lets the `httpd_t` domain read files of type `var_t`. Fix the file's label, not a path rule.
</details>

<details>
<summary>7. Why is <code>chcon</code> not the fix you hand over?</summary>

It changes only the live label and leaves the file-context database alone. The next relabel sets the file back to what the database says. Use `semanage fcontext -a` and then `restorecon -Rv`.
</details>

<details>
<summary>8. nginx must listen on a new port on an SELinux machine. Which two things must be true?</summary>

The port must be in a port type the `httpd_t` domain may bind (check with `semanage port -l`, add with `semanage port -a` if it is missing), and nginx's own configuration must say `listen` on that port.
</details>

## Clean up the playground

When you are done with this module, remove the playground and any mission that is still running.

First, see what is still running:

```sh
astrona list
```

Remove the playground. The command takes its **name**, not its folder path:

```sh
astrona destroy apparmor-mac-enforcement
```

If `astrona list` also showed a mission, remove it the same way, for example:

```sh
astrona destroy ats-002-lab-041
astrona destroy ats-002-lab-042
```

Run `astrona list` again to check that everything is gone. You can start the playground again at any time with the `astrona run` command from the module's landing page. It always starts clean, so nothing you broke carries over.

> *Two gates sit between a process and a file. When the permissions look right and the action still fails, ask the security chief: read the denial, add exactly the rule it names, reload, and leave the gate enforcing.*
