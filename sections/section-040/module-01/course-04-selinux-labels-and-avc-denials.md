# Part 4 — SELinux: labels, contexts, and the AVC denial

> Prerequisite: [Part 3 — AppArmor: diagnosing and fixing a path denial](./course-03-apparmor-diagnosing-and-fixing.md). Next: [Part 5 — SELinux: persistent fixes and the AppArmor contrast](./course-05-selinux-persistent-fixes-and-contrast.md).

The playground runs AppArmor, so from here on there is **no machine to type these commands into** — this part and the next are a worked walkthrough of what you would do on a RHEL-family host, which is what the LFCS objective actually names. Read it as carefully as the hands-on parts: the reasoning is the same shape as Part 3, the mechanism underneath is entirely different. This part covers how SELinux decides and how to read a denial; Part 5 covers the fix.

## The second gate, rebuilt around labels

Part 1's rule: SELinux matches on a **label**, not a path. Precisely, every process and every file (and port, and more) carries a **security context** — four colon-separated fields:

```
   system_u : system_r : httpd_t : s0
   ───┬────   ───┬────   ──┬───    ─┬
    user       role      type    level (MLS/MCS; often just s0)
```

- **user** — the SELinux user (not the Unix user; `system_u`, `unconfined_u`, …). Rarely what you tune.
- **role** — used with SELinux users for RBAC; `system_r` for daemons, `object_r` for files.
- **type** — **the field policy decisions actually turn on.** A process runs in a *domain* type (`httpd_t`, `sshd_t`); a file has a *file* type (`httpd_sys_content_t`, `var_t`, `etc_t`).
- **level** — MLS/MCS sensitivity; on a targeted-policy host it is `s0` almost everywhere.

The policy is, at heart, one big table of rules of the form "domain **X** may perform action **Y** on type **Z**": `allow httpd_t httpd_sys_content_t : file { read getattr open };`. If no `allow` rule covers the (domain, type, action) triple, it is denied — SELinux is **default-deny**.

Because the decision is `httpd_t`-reads-`httpd_sys_content_t`, and not "anything under `/var/www`", **moving a correctly-labelled file to a weird path usually keeps working** — the label came with it. The mirror of Part 1's AppArmor consequence.

## Checking whether SELinux is even in play

Three modes — one more than AppArmor:

| SELinux | Meaning | AppArmor analogue |
|---|---|---|
| **Enforcing** | policy denials are blocked and logged | `enforce` |
| **Permissive** | denials are logged, action allowed | `complain` |
| **Disabled** | SELinux LSM off entirely | (no AppArmor equivalent — AppArmor has no "disabled at runtime") |

```bash
# shell: RHEL-family host, unprivileged
getenforce
```

```text
Enforcing
```

```bash
sudo setenforce 0    # -> Permissive, until reboot or 'setenforce 1'
sudo setenforce 1    # -> Enforcing
```

`setenforce` toggles only between Enforcing and Permissive, and only until reboot. Going to or from **Disabled** is a change to `/etc/selinux/config` (`SELINUX=disabled`) plus a reboot — and coming back from Disabled forces a full filesystem relabel on next boot, because labels went stale while it was off. `sestatus` prints the fuller picture (current mode, config-file mode, policy name, mount point).

The exam-relevant instinct: a "correct permissions, still denied" symptom (Part 1) on a RHEL host → run `getenforce` first. `Permissive` or `Disabled` and the denial persists → not SELinux, look elsewhere. `Enforcing` → carry on to the context check.

## Worked scenario: nginx, a moved docroot, and a 403

The canonical trap, end to end. An nginx server has been pointed at `/srv/webdata` instead of the default `/var/www/html`. `ls -l` shows correct owner and mode. Every request returns **403 Forbidden**.

**Step 1 — is SELinux even enforcing here?**

```bash
getenforce
```

```text
Enforcing
```

**Step 2 — look past DAC at the label, with `-Z`.** `-Z` is the flag that shows SELinux context on `ls`, `ps`, `id`, `cp`, `netstat`/`ss`, and more:

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

The file's type is **`var_t`** — the generic type anything under `/srv` inherits by default, because `/srv` has no more specific rule. The nginx process runs in domain **`httpd_t`**. Policy has `allow httpd_t httpd_sys_content_t : file read` — it has **no** rule letting `httpd_t` read `var_t`. That type mismatch, not the mode bits, is the 403.

**Step 3 — confirm it in the audit trail.** SELinux denials are **AVC** (Access Vector Cache) records. With `auditd` running they go to `/var/log/audit/audit.log`; read them with `ausearch`:

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

Field by field, and notice how different it is from Part 3's AppArmor line:

| Field | Meaning |
|---|---|
| `avc: denied { read }` | the permission(s) refused — here `read` (could be `{ write open getattr }`, etc.) |
| `scontext=...:httpd_t:s0` | **source context** — the *process's* domain. The actor. |
| `tcontext=...:var_t:s0` | **target context** — the *object's* type. What it tried to touch. |
| `tclass=file` | the object class — `file`, `dir`, `tcp_socket`, `lnk_file`, … |
| `comm` / `name` / `ino` | process name, the target's basename, its inode — locate the object, but they are not what policy checked |
| `permissive=0` | `0` = Enforcing blocked it; `1` = it was only logged |

The denial is stated as a relationship: **`httpd_t` may not `read` a `file` of type `var_t`.** There is no "the path had no rule" here — the fix (Part 5) is to change the *label*, not to add a path.

> [!WARNING]
> On a busy Enforcing host, one root cause often produces a burst of AVCs (read, then getattr, then open, on several files). Fix the **first** denial's cause and re-test before chasing the rest — most of the burst is the same label mismatch seen from different syscalls. `ausearch -m avc -ts recent` limits the noise to the last few minutes; `-ts today` or `-ts 09:00:00` narrows it further.

> [!WARNING]
> `permissive=1` in an AVC (or `getenforce` → `Permissive`) means the action was **allowed** and only logged — the same trap as an AppArmor profile left in `complain`. A denial you "fixed" while Permissive is unproven until you are back in `Enforcing` and re-test.

> *SELinux decides by the `type` field of a security context: `ausearch -m avc` shows `scontext` (the process domain) and `tcontext` (the object type), and a denial means policy has no `allow` rule for that domain acting on that type — a label problem, not a path problem.*

## Reference

- `man 8 selinux`, `man 8 sestatus` — the model overview and the one command that dumps current + configured mode and policy.
- `man 1 ausearch` — `-m avc`, `-ts`/`-te` time windows, `-i` to interpret numeric fields; the primary AVC reader.
- `man 8 sealert` / `journalctl -t setroubleshoot` — when `setroubleshoot-server` is installed, plain-language explanations and suggested fixes for each AVC.
