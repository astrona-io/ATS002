# Persistent SELinux Fixes And The AppArmor Contrast

The worked example ended with a proven label mismatch: `httpd_t` cannot read a file of type `var_t`. This part is the fix, and the exam trap where the *obvious* fix is the wrong one. Then it puts the two MAC systems side by side, so you can say how you would do the same job under the other one. This is still a walkthrough: the Ubuntu training ship cannot run SELinux, so these commands are for a RHEL-family machine.

## The tempting wrong fix: `chcon`

The first idea most people have is to set the type directly:

```bash
# shell: RHEL-family host, root
sudo chcon -t httpd_sys_content_t /srv/webdata/index.html   # do NOT stop here
```

`chcon` (**ch**ange **con**text) writes the label straight onto the file, right now. The 403 goes away at once. Then, some time later, it quietly comes back.

Here is why. SELinux keeps a lasting **file-context database**: a list of path patterns and the type that files there *should* have. `chcon` does **not** touch that database. It changes only the live label. The next time anything relabels the filesystem, the file is set back to what the **database** says, which is still `var_t`. That can be a `restorecon` run, `dnf` updating a policy package, a `/.autorelabel` file and a reboot, or an administrator fixing something else. The fix disappears with no clear cause.

In space terms, `chcon` is a sticky note on the crate's security tag. `semanage fcontext` (below) changes the ship's official tag register, and then the tag is reprinted from it. Anyone who reprints tags from the register, which routine maintenance does, brushes the sticky note off. The register entry survives. The catch is that a real sticky note looks temporary, while a `chcon` change looks exactly like a lasting one until the day it is gone.

`chcon` is fine for a truly temporary test ("is the label really the problem?"). It is never the fix you hand over.

## The persistent fix: `semanage fcontext` and `restorecon`

The lasting fix is two commands, in this order, every time:

```bash
# shell: RHEL-family host, root
sudo semanage fcontext -a -t httpd_sys_content_t '/srv/webdata(/.*)?'
sudo restorecon -Rv /srv/webdata
```

Each command does one half of the job. Together they make the fix survive any later relabel.

### What `semanage fcontext` does

`semanage` (**SE**Linux **manage**) edits the lasting policy settings: file contexts, ports, booleans and users. `fcontext` is the file-context table, and `-a` adds a rule. The path is an **extended regular expression**, a text pattern: `'/srv/webdata(/.*)?'` means "`/srv/webdata` itself, and anything below it". This command **only writes the database entry**. It does not touch a single file yet. `semanage fcontext -l | grep webdata` shows that the rule is there.

### What `restorecon` does

`restorecon` (**restore con**text) reads the database and relabels the real files on disk to match it. `-R` works through every folder below, and `-v` prints each change. *This* step fixes the live labels, and because they now match the database, the fix lasts:

```text
Relabeled /srv/webdata from unconfined_u:object_r:var_t:s0 to unconfined_u:object_r:httpd_sys_content_t:s0
Relabeled /srv/webdata/index.html from ...:var_t:s0 to ...:httpd_sys_content_t:s0
```

Run `restorecon` again next month, or let a policy update relabel the files: nothing changes, because the database already holds the right answer. That is the whole point of two steps instead of one `chcon`. `fixfiles` applies the same database to the whole filesystem at once.

## A separate gate: port types

File labels are not the only thing SELinux checks. Say the same nginx must also listen on TCP port **8443**. That has nothing to do with file labels. SELinux controls which ports a domain may `bind()` to (start listening on) through **port types**, a different kind of object.

### Check before you add

```bash
# shell: RHEL-family host
sudo semanage port -l | grep '^http_port_t'
```

```text
http_port_t    tcp    80, 81, 443, 488, 8008, 8009, 8443, 9000
```

The usual targeted policy already lists `8443` under `http_port_t` here. `semanage port -a` on a port that already has a type **fails** with `ValueError: Port tcp/8443 already defined`. If a port really is not covered, add it:

```bash
sudo semanage port -a -t http_port_t -p tcp 9300
```

### Two settings, two places

The two settings do not depend on each other. SELinux allowing `httpd_t` to bind port 8443 does **not** make nginx listen there: you still add `listen 8443;` to nginx's own configuration. The other way round, adding `listen 8443;` without the port type (when the port is missing from the list) makes nginx's bind fail with `EACCES`. Both must be true, and you set them in different places.

A third common SELinux setting is the **boolean**: an on/off switch in the policy, such as `httpd_can_network_connect`. `getsebool -a` lists them, and `semanage boolean` changes them for good. This module does not cover them, but they are the next thing to learn.

## AppArmor and SELinux side by side

The two systems solve the same problem, a mandatory second gate behind DAC, in different ways. This table puts every tool from this module next to its counterpart:

| | AppArmor | SELinux |
|---|---|---|
| Decides by | the exact filesystem **path** | the security **label**, mainly its `type` |
| Ships enforcing on | Ubuntu, Debian, openSUSE | RHEL, Fedora, Rocky, Alma |
| Running modes | `enforce` / `complain` | `Enforcing` / `Permissive` / `Disabled` |
| "Which mode?" | `aa-status` | `getenforce` / `sestatus` |
| See what the decision uses | `cat /etc/apparmor.d/<profile>` | `ls -Z`, `ps -Z` |
| Denial record | `journalctl -k`, `apparmor="DENIED" ... name=<path>` | `ausearch -m avc`, `scontext` / `tcontext` |
| Temporary or wrong fix | (none: a profile edit only takes effect after a reload) | `chcon`, lost at the next relabel |
| Lasting fix | edit `/etc/apparmor.d/local/…` or use `aa-logprof`, then `apparmor_parser -r` | `semanage fcontext -a`, then `restorecon -Rv` |
| Reload or apply step | `apparmor_parser -r <profile>` | `restorecon` (files) / automatic (booleans, ports) |
| Move a file to a new path | the old path rule stops matching, so the profile needs a new rule | usually still works, because the label moved with the file |

The sentence to know by heart:

> **AppArmor asks "is this exact path in this program's profile?" SELinux asks "what type is this object, and does this process's domain have an `allow` rule for that type?"**

To know which half of the table to use, find out which system is in front of you. Check the distribution, read `/sys/kernel/security/lsm`, or see which of `aa-status` and `getenforce` exists.

## Common pitfalls

> [!WARNING]
> - **Running only half of the lasting fix.** `semanage fcontext -a` alone changes nothing you can see: it writes the rule but does not relabel, so the file keeps its old label and the denial stays. `chcon` alone does the opposite: it relabels now and is forgotten at the next relabel. You need **both halves**, the rule *and* the relabel, and `semanage` plus `restorecon` is that pair.
> - **Adding a port type that already exists.** `semanage port -a` fails on a port that already has a type. If a service cannot bind a port that *is* already in the right type list, the SELinux port policy is fine. Look at the capability to bind low ports (`CAP_NET_BIND_SERVICE`, for ports below 1024), another program already listening, or the service's own configuration. Do not force a second `semanage` rule.
> - **Fixing only the SELinux side of a port.** The port type allows the bind; it does not make the service listen. Change the service's own configuration too.

> *Lasting SELinux fixes go through the file-context database: `semanage fcontext -a` writes the rule, and `restorecon -Rv` relabels the files to match it. `chcon` skips the database and is undone by the next relabel. Ports are a separate table, changed with `semanage port`.*
