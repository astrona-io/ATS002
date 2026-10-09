# SELinux Labels And AVC Denials

Astronaut, this part is a worked walkthrough, not a hands-on step. Your playground runs AppArmor, and the Ubuntu training ship cannot run SELinux, so there is **no machine here to type these commands into**. What follows is what you would do on a RHEL-family machine (Red Hat Enterprise Linux, Rocky, AlmaLinux, Fedora), which is the system the LFCS exam objective names. Read it as carefully as the hands-on parts: the reasoning has the same shape as with AppArmor, but the machinery underneath is completely different.

## The second gate, rebuilt around labels

SELinux matches a **label**, not a path. Every process and every file (and port, and more) carries a **security context**: a label made of four fields separated by colons. Picture it as a security tag stuck on every crew member and every crate. The rules compare tags, not addresses.

### The four fields of a context

```
   system_u : system_r : httpd_t : s0
   ───┬────   ───┬────   ──┬───    ─┬
    user       role      type    level (MLS/MCS; often just s0)
```

- **user** is the SELinux user. It is not the Unix user: examples are `system_u` and `unconfined_u`. You rarely change it.
- **role** is used with SELinux users for role-based access control. Daemons use `system_r`, files use `object_r`.
- **type** is **the field the policy decisions really depend on.** A process runs in a *domain* type (`httpd_t`, `sshd_t`). A file has a *file* type (`httpd_sys_content_t`, `var_t`, `etc_t`).
- **level** is the sensitivity level, used by multi-level security (MLS) and multi-category security (MCS). On a machine with the usual "targeted" policy it is `s0` almost everywhere.

### Rules about types

At heart, the policy is one big table of rules like "domain **X** may do action **Y** on type **Z**":

```text
allow httpd_t httpd_sys_content_t : file { read getattr open };
```

If no `allow` rule covers the domain, the type and the action together, SELinux denies it. SELinux is **deny by default**.

The decision is "can `httpd_t` read `httpd_sys_content_t`", not "is the file under `/var/www`". So **moving a correctly labelled file to an odd path usually keeps it working**: the label moved with it. That is the mirror image of AppArmor, where a moved file stops matching its old path rule.

## Checking whether SELinux is even in play

SELinux has three modes, one more than AppArmor. Before you look at labels, find out which mode the machine is in.

### The three modes

| SELinux | Meaning | AppArmor counterpart |
|---|---|---|
| **Enforcing** | policy denials are blocked and logged | `enforce` |
| **Permissive** | denials are logged, but the action is allowed | `complain` |
| **Disabled** | SELinux is switched off completely | (no AppArmor counterpart: AppArmor has no "disabled while running") |

On a RHEL-family machine, `getenforce` prints the current mode:

```bash
# shell: RHEL-family host, unprivileged
getenforce
```

```text
Enforcing
```

`setenforce` switches between the two running modes:

```bash
sudo setenforce 0    # -> Permissive, until reboot or 'setenforce 1'
sudo setenforce 1    # -> Enforcing
```

### Switching modes for good

`setenforce` only moves between Enforcing and Permissive, and only until the next reboot. To switch SELinux to or from **Disabled**, you change `/etc/selinux/config` (`SELINUX=disabled`) and reboot. Coming back from Disabled forces a full relabel of the filesystem at the next boot, because labels went out of date while SELinux was off. `sestatus` prints the fuller picture: the current mode, the mode in the configuration file, the policy name and where SELinux is mounted.

The exam habit: you see "correct permissions, still denied" on a RHEL machine, so run `getenforce` first. If it says `Permissive` or `Disabled` and the denial is still there, SELinux is not the cause; look elsewhere. If it says `Enforcing`, go on to check the labels.

## Worked example: nginx, a moved web folder and a 403

This is the classic trap, from start to end. An nginx web server has been pointed at `/srv/webdata` instead of the default `/var/www/html`. `ls -l` shows the correct owner and mode. Every request returns **403 Forbidden**. Follow the three steps below on a RHEL-family machine.

### Step 1: is SELinux enforcing here?

```bash
getenforce
```

```text
Enforcing
```

### Step 2: look past DAC at the label

The `-Z` option shows the SELinux context. It works on `ls`, `ps`, `id`, `cp`, `netstat` and `ss`, and more:

```bash
ls -Z /srv/webdata/index.html
```

```text
unconfined_u:object_r:var_t:s0 /srv/webdata/index.html
```

```bash
ps -eZ | grep nginx
```

```text
system_u:system_r:httpd_t:s0    1234 ?  00:00:00 nginx
```

The file's type is **`var_t`**: the general type that everything under `/srv` gets by default, because no more specific rule covers `/srv`. The nginx process runs in the domain **`httpd_t`**. The policy has `allow httpd_t httpd_sys_content_t : file read`, but it has **no** rule that lets `httpd_t` read `var_t`. That type mismatch, not the mode bits, causes the 403.

### Step 3: confirm it in the audit log

SELinux writes its denials as **AVC** records. AVC stands for Access Vector Cache, the part of SELinux in the kernel that remembers recent decisions. An AVC denial is SELinux's report of a tag that did not match. With the `auditd` daemon running, these records go to `/var/log/audit/audit.log`, and you read them with `ausearch`:

```bash
sudo ausearch -m avc -ts recent
```

```text
type=AVC msg=audit(...): avc:  denied  { read } for  pid=1234 comm="nginx"
  name="index.html" dev="vda1" ino=98304
  scontext=system_u:system_r:httpd_t:s0
  tcontext=unconfined_u:object_r:var_t:s0
  tclass=file permissive=0
```

### Reading the AVC fields

Field by field. Notice how different this is from an AppArmor `DENIED` line, which names a profile and a path:

| Field | Meaning |
|---|---|
| `avc: denied { read }` | the permission that was refused, here `read` (it could also be `{ write open getattr }` and so on) |
| `scontext=...:httpd_t:s0` | **source context**: the *process's* domain. Who acted |
| `tcontext=...:var_t:s0` | **target context**: the *object's* type. What it tried to touch |
| `tclass=file` | the kind of object: `file`, `dir`, `tcp_socket`, `lnk_file` and more |
| `comm` / `name` / `ino` | the process name, the target's base name and its inode number. They help you find the object, but the policy did not check them |
| `permissive=0` | `0` = Enforcing blocked it; `1` = it was only logged |

The denial is a relationship: **`httpd_t` may not `read` a `file` of type `var_t`.** There is no "this path had no rule" here. So the fix is to change the *label*, not to add a path.

When `setroubleshoot-server` is installed, `sealert` and `journalctl -t setroubleshoot` explain each AVC in plain words and suggest a fix. `ausearch -i` turns number fields into readable names.

## Common pitfalls

> [!WARNING]
> - **Chasing every AVC in a burst.** On a busy Enforcing machine, one cause often makes many AVCs (read, then getattr, then open, on several files). Fix the cause of the **first** denial and test again before you chase the rest: most of the burst is the same label mismatch seen from different system calls. `ausearch -m avc -ts recent` limits the output to the last few minutes; `-ts today` or `-ts 09:00:00` sets another start time.
> - **Trusting a fix made while Permissive.** `permissive=1` in an AVC, or `Permissive` from `getenforce`, means the action was **allowed** and only logged. It is the same trap as an AppArmor profile left in complain mode. A denial you "fixed" while Permissive is not proven until you are back in `Enforcing` and test again.
> - **Thinking `setenforce` lasts.** It only holds until the next reboot. The lasting mode is in `/etc/selinux/config`.

> *SELinux decides by the `type` field of a security context. `ausearch -m avc` shows `scontext` (the process domain) and `tcontext` (the object type), and a denial means the policy has no `allow` rule for that domain acting on that type. It is a label problem, not a path problem.*
