# Part 5 — SELinux: persistent fixes and the AppArmor contrast

> Prerequisite: [Part 4 — SELinux: labels, contexts, and the AVC denial](./course-04-selinux-labels-and-avc-denials.md). Next: [Section 040 quiz](../quiz.md).

Part 4 ended with a confirmed label mismatch: `httpd_t` can't read a `var_t` file. This part is the fix — and the exam trap that the *obvious* fix is the wrong one. Then the two systems side by side, so you can answer "how would you do this under the other one" on demand. Still a walkthrough: no SELinux VM here.

## The tempting wrong fix: `chcon`

The immediate instinct is to just set the type:

```bash
# shell: RHEL-family host, root
sudo chcon -t httpd_sys_content_t /srv/webdata/index.html   # do NOT stop here
```

`chcon` — **ch**ange **con**text — writes the label directly onto the file's inode, right now. The 403 clears immediately. And then it silently breaks again later, because:

SELinux keeps a **persistent file-context database** — a list of path patterns → the type files there *should* have. `chcon` does **not** touch that database. It changes the live label only. The next time anything relabels the filesystem — a `restorecon` run, `dnf` updating a policy package, a touch of `/.autorelabel` then reboot, an admin fixing something unrelated — the file is set back to whatever the **database** says, which is still `var_t`. The fix evaporates with no obvious cause.

As an analogy: `chcon` is a **sticky note** stuck on the file. `semanage fcontext` (below) is editing the **system's book of record**, then reprinting the file's label from it. Anyone who reprints labels from the book — which routine maintenance does — brushes the sticky note off; the book entry survives. Where it breaks down: a sticky note is visibly temporary, whereas `chcon`'s change looks identical to a permanent one until the day it isn't.

`chcon` is legitimate for a genuinely temporary test ("is the label really the problem?") — but never as the delivered fix.

## The persistent fix: `semanage fcontext` + `restorecon`

Two commands, in this order, every time:

```bash
# shell: RHEL-family host, root
sudo semanage fcontext -a -t httpd_sys_content_t '/srv/webdata(/.*)?'
sudo restorecon -Rv /srv/webdata
```

**`semanage fcontext -a -t <type> '<path regex>'`** — `semanage` = **SE**Linux **manage**, the tool that edits the persistent policy configuration (file contexts, ports, booleans, users). `fcontext` = the file-context table. `-a` = add a rule. The path is an **extended regular expression**: `'/srv/webdata(/.*)?'` means "`/srv/webdata` itself, and optionally anything below it." This command **only writes the database entry** — it does not touch a single file yet. `semanage fcontext -l | grep webdata` shows it landed.

**`restorecon -Rv <path>`** — **restore con**text: read the database, and relabel the real files on disk to match it. `-R` recursive, `-v` verbose (prints each change). *This* is the step that fixes the live labels — but now they match the database, so the fix is permanent:

```text
Relabeled /srv/webdata from unconfined_u:object_r:var_t:s0 to unconfined_u:object_r:httpd_sys_content_t:s0
Relabeled /srv/webdata/index.html from ...:var_t:s0 to ...:httpd_sys_content_t:s0
```

Run `restorecon` again next month, or let a policy update trigger a relabel — it is now a safe no-op, because the database already carries the right answer. That is the whole point of doing it in two steps instead of one `chcon`.

> [!WARNING]
> `semanage fcontext -a` alone changes nothing you can see — it writes the rule but does not relabel. If you add the rule and don't run `restorecon`, the file keeps its old label and the denial persists. `chcon` alone does the opposite: relabels now, forgets by the next relabel. You need **both halves** — rule *and* relabel — and `semanage` + `restorecon` is that pair.

## A separate mechanism: port-type policy

File context is not the only thing SELinux gates. Say the same nginx must also listen on TCP **8443**. That has nothing to do with file labels — SELinux controls which ports a domain may `bind()` through **port types**, a different object class:

```bash
# shell: RHEL-family host
sudo semanage port -l | grep '^http_port_t'
```

```text
http_port_t    tcp    80, 81, 443, 488, 8008, 8009, 8443, 9000
```

Check before adding: targeted policy already lists `8443` under `http_port_t` here, and `semanage port -a` on a port that already has a type **errors out** (`ValueError: Port tcp/8443 already defined`). If a port genuinely isn't covered:

```bash
sudo semanage port -a -t http_port_t -p tcp 9300
```

And note the independence: SELinux allowing `httpd_t` to bind 8443 does **not** make nginx listen there — you still edit `listen 8443;` in nginx's own config. Conversely, adding `listen 8443;` without the port type (when it's missing) gets nginx an `EACCES` on bind. Both conditions have to be true; they are set in different places.

> [!WARNING]
> `semanage port -a` fails on an already-assigned port. When a service can't bind a port that *is* already in the right type list, the SELinux port policy is fine — look at DAC capabilities (`CAP_NET_BIND_SERVICE` for ports < 1024), a conflicting listener, or the service config. Don't force a second `semanage` rule.

## AppArmor vs SELinux, side by side

| | AppArmor (Parts 2–3) | SELinux (Parts 4–5) |
|---|---|---|
| Decides by | literal filesystem **path** | security **label**, specifically the `type` |
| Ships enforcing on | Ubuntu, Debian, openSUSE | RHEL, Fedora, Rocky, Alma |
| Runtime modes | `enforce` / `complain` | `Enforcing` / `Permissive` / `Disabled` |
| "Which mode?" | `aa-status` | `getenforce` / `sestatus` |
| See the deciding attribute | `cat /etc/apparmor.d/<profile>` | `ls -Z`, `ps -Z` |
| Denial record | `journalctl -k`, `apparmor="DENIED" ... name=<path>` | `ausearch -m avc`, `scontext` / `tcontext` |
| Temporary/wrong fix | (none — a profile edit is only live after reload) | `chcon` — lost on the next relabel |
| Persistent fix | edit `/etc/apparmor.d/local/…` or `aa-logprof`, then `apparmor_parser -r` | `semanage fcontext -a`, then `restorecon -Rv` |
| Reload/apply step | `apparmor_parser -r <profile>` | `restorecon` (files) / automatic (booleans, ports) |
| Move a file to a new path | old path rule stops matching → profile needs a new rule | usually still works → the label travelled with the file |

The sentence to be able to say cold:

> **AppArmor asks "is this exact path in this program's profile?" SELinux asks "what type is this object, and does this process's domain have an `allow` rule for that type?"**

Same problem — a mandatory second gate behind DAC — solved by matching on the path versus matching on the label. Recognising *which* system is in front of you (Part 1: check the distro, or `/sys/kernel/security/lsm`, or which of `aa-status` / `getenforce` exists) tells you which half of this table to use.

> *Persistent SELinux fixes go through the file-context database: `semanage fcontext -a` writes the rule, `restorecon -Rv` relabels files to match it — `chcon` skips the database and is undone by the next relabel; ports are a separate `semanage port` table.*

## Reference

- `man 8 semanage`, `man 8 semanage-fcontext`, `man 8 semanage-port` — the persistent-policy editor and its `fcontext` / `port` / `boolean` sub-tables.
- `man 8 restorecon`, `man 8 fixfiles` — applying the file-context database to disk, one path or the whole filesystem.
- `man 8 chcon` — the direct relabel, and its own note that changes are lost on `restorecon` / relabel.
- `getsebool -a` / `man 8 semanage-boolean` — the third common SELinux knob (on/off policy switches like `httpd_can_network_connect`), not covered here but the next thing to learn.
