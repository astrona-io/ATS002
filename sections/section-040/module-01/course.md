# AppArmor Profile Enforcement & the Other MAC System: SELinux

Every file on a Linux system already has an owner, a group, and a set of read/write/execute bits. That's Discretionary Access Control (DAC) — "discretionary" because the resource's *owner* decides who gets in. It's the gate you already know.

Mandatory Access Control (MAC) is a second gate, standing behind the first one, that the resource owner does not control at all. A system-wide security policy decides whether a process may touch a file, independent of what the rwx bits say. Both gates have to open before an action succeeds. A process can have textbook-perfect DAC permissions — `ls -l` looks completely normal — and still get slammed by the second gate. That combination, correct permissions plus a mysterious denial, is the single most important signature to recognize on the exam: it means stop checking `chmod` and start checking whichever MAC system is running.

Linux has two mainstream MAC implementations, and which one you meet depends entirely on which distribution family you're standing on. RHEL, CentOS, Fedora, and Rocky ship **SELinux**. Ubuntu, Debian, and openSUSE ship **AppArmor**. This machine — the one your lab VM boots from — is Ubuntu 24.04, so AppArmor is what's actually loaded into your kernel and actively enforcing right now. That's why Part I of this module is hands-on and graded: you will break something, diagnose it for real, and fix it for real. Part II covers SELinux conceptually, because the exam objective is written as "create and enforce MAC using SELinux" and a competent LFCS candidate needs to recognize and reason about both systems — but there is no SELinux kernel on this image to practice against, and that's said plainly, not apologetically.

---

## Part I: AppArmor — Path-Based Mandatory Access Control (Hands-On)

### The core idea: a guest list by address, not by name

Imagine a building where every visitor is checked against a guest list before an elevator will move. SELinux's version of that list is organized by *name tag* — every person (every file) is issued a badge with a category printed on it, and the list says which badge categories may ride which elevators. AppArmor's version of that list is organized by *street address* — the guard doesn't care what badge you're wearing, only whether the exact address you're heading to (the exact filesystem path) appears on this particular visitor's approved list.

That's the whole conceptual difference, and it has a very concrete consequence: rename or move a file under SELinux, and its badge usually travels with it or gets reassigned by directory defaults. Rename or move a file under AppArmor, and the *old* path rule stops matching entirely — the profile has no idea the file "used" to be something it recognized. AppArmor profiles are lists of filesystem paths a given program may touch, and how, matched directly against the literal path string being accessed.

### Checking what's loaded: aa-status

Before diagnosing anything, confirm AppArmor is actually active and see what it currently knows about:

```bash
sudo aa-status
```

```text
apparmor module is loaded.
15 profiles are loaded.
13 profiles are in enforce mode.
   /usr/sbin/appservice
   ...
2 profiles are in complain mode.
   ...
3 processes have profiles defined.
2 processes are in enforce mode.
   /usr/sbin/appservice (1234)
```

This single command answers three questions at once: is the AppArmor module loaded at all, which profiles exist, and — critically — which *mode* each profile is running in. A profile can be loaded but sitting in `complain` mode, in which case it is doing nothing to stop anything (more on that in a moment). `aa-status --help` is worth reading; the man page for `aa-status` itself is thin, and in practice the `--help` text covers the same ground just as fast.

### Reading a profile file

Profiles live under `/etc/apparmor.d/`, named after the confined program's path with the slashes turned into dots — `/usr/sbin/appservice` becomes the file `/etc/apparmor.d/usr.sbin.appservice`. Here is a realistic one:

```text
#include <tunables/global>

/usr/sbin/appservice {
  #include <abstractions/base>
  #include <abstractions/bash>

  /usr/sbin/appservice r,
  /bin/bash ix,
  /usr/bin/sleep rix,

  /var/log/appservice/ r,
  /var/log/appservice/*.log rw,
}
```

Read it top to bottom: `#include <tunables/global>` and `#include <abstractions/base>` pull in shared boilerplate (common shared-library paths, `/dev/null`, locale files) that almost every profile needs and nobody wants to retype. Inside the block, each bare line is a **path rule**: a filesystem path (which may include a `*` glob) followed by an access-mode list — `r` read, `w` write, `ix` execute-and-inherit-this-same-profile, and a few others documented in `man apparmor.d`. `capability` lines, when present, are a completely different rule type granting a specific Linux capability, not a path.

Look at what this profile actually permits: read/write under `/var/log/appservice/`. Nothing else. If this program is ever reconfigured to log somewhere else, every write to the new location gets refused — not because anyone misconfigured `chown` or `chmod`, but because the profile simply has no rule covering that new path.

### enforce vs. complain

Every loaded profile sits in one of two modes:

- **enforce** — actively blocks anything the profile doesn't permit. This is the "real" MAC gate, doing its job.
- **complain** — logs what *would* have been denied, but lets the action through anyway. Nothing is actually blocked in this mode.

`complain` mode exists for exactly one legitimate purpose: observing what a program genuinely needs to do, without breaking it, while you build out its profile. It is never a legitimate *permanent* fix. Switch a single profile between modes without touching any other loaded profile:

```bash
sudo aa-complain /usr/sbin/appservice   # observe only, don't block
sudo aa-enforce  /usr/sbin/appservice   # back to actually confining it
```

Both are thin wrapper tools — check their own `--help` output rather than hunting for a deep man page.

### Finding the denial in the audit trail

AppArmor denials are written through the kernel's audit subsystem, which lands in the kernel ring buffer whether or not a full `auditd` daemon is running. You read that with `dmesg` or, more durably (it survives a `dmesg` buffer wraparound), `journalctl -k`:

```bash
sudo journalctl -k | grep 'apparmor="DENIED"'
```

```text
audit: type=1400 audit(...): apparmor="DENIED" operation="open" profile="/usr/sbin/appservice" name="/srv/applogs/app.log" pid=1234 comm="appservice" requested_mask="w" denied_mask="w" fsuid=1001 ouid=1001
```

Every field earns its place: `profile=` is which profile did the denying, `operation="open"` plus `requested_mask="w"`/`denied_mask="w"` show exactly what was attempted and refused, and `name=` is the literal path that triggered it — the exact string that needs a matching, permitting rule in the profile before this will ever succeed. Notice there is no label field anywhere in that line. Everything AppArmor reasoned about here is the path string alone, unlike an SELinux AVC denial (Part II), which centers on a pair of security contexts instead.

### Fixing it: hand-edit, or let the tool watch and suggest

You have two ways to close the gap, and they aren't mutually exclusive.

**Option A — edit the profile directly.** Ubuntu profiles commonly ship with a companion local-override mechanism specifically so a package upgrade never clobbers your local additions: a file under `/etc/apparmor.d/local/`, pulled in via a soft include at the bottom of the main profile:

```text
#include if exists <local/usr.sbin.appservice>
```

`#include if exists` (as opposed to a bare `#include`) tolerates the target file not existing — which is exactly the state a freshly-packaged profile ships in before any admin has customized it. Append the missing rule there:

```bash
sudo tee -a /etc/apparmor.d/local/usr.sbin.appservice > /dev/null << 'EOF'
/srv/applogs/*.log rw,
/srv/applogs/ r,
EOF
```

Then reload:

```bash
sudo apparmor_parser -r /etc/apparmor.d/usr.sbin.appservice
```

`apparmor_parser -r` reparses and reloads a single profile into the running kernel — this is the AppArmor equivalent of `systemctl daemon-reload` after editing a unit file. Skipping it is the single most common "I fixed the profile but the write still fails" mistake: the file on disk changed, but the kernel is still enforcing the old, unmodified copy until you reload it.

**Option B — let `aa-logprof` read the denial and propose the rule.** Reproduce the failing action to generate a fresh log entry, then:

```bash
sudo aa-logprof
```

`aa-logprof` scans recent AppArmor denial events and, for each one it hasn't already accounted for, shows you the operation and path along with one or more suggested rule variants — an exact-path rule versus a directory glob, for instance — and asks you to accept, adjust, or reject each one before writing your choice into the profile and reloading it. It's *semi*-interactive on purpose: how broad a rule should be is a judgment call the tool deliberately leaves to a human, rather than silently guessing either an overly-narrow rule (which breaks on the next legitimate variation) or an overly-broad one (which defeats the point of confinement in the first place).

### Confirming the fix is real, not a shortcut

If diagnosis involved switching the profile to `complain` mode to observe safely, that is not the finish line — switch it back:

```bash
sudo aa-enforce /usr/sbin/appservice
sudo aa-status | grep -A1 appservice
```

A profile left in `complain` mode will make the failing action "succeed" too — but only because nothing is actually being checked anymore, not because the underlying rule gap was closed. A grader (or a real security review) checking for genuine enforcement treats a complain-mode profile as still broken, even though the specific write now goes through.

---

## Part II: The Other MAC System — SELinux (Conceptual Walkthrough — Not Graded Here)

**A direct note before you read any further:** this lab environment is Ubuntu 24.04, which runs AppArmor, not SELinux. Turning on real SELinux enforcement requires swapping which Linux Security Module the kernel boots with (`security=selinux`) and a full filesystem relabel — a fragile, multi-reboot operation that has no safe place in an automated, gradable lab bootstrap. So this section is a **walkthrough, not a lab**. There is no VM here for you to practice SELinux commands against. What follows is the exact reasoning and command sequence you'd use on a RHEL-family exam host, worked through in full — read it as carefully as you'd read a hands-on section, because the exam competency explicitly names SELinux, and RHEL-family exam images run it for real.

### The same two gates, a completely different second lock

SELinux implements MAC through **security contexts** — labels — rather than paths. Every process and every file carries a four-part label: `user:role:type:level`. Policy decisions are keyed almost entirely on the **type** component. A web server process runs under a process type like `httpd_t`; files it's allowed to read are labeled with content types like `httpd_sys_content_t`. The policy is, at its core, a giant table of "type X may perform action Y against type Z." Move a file to a completely different directory under SELinux, and — unlike AppArmor — its behavior often *doesn't* change, because what matters is the label it's still wearing, not the address it now lives at.

### Checking mode: getenforce / setenforce

SELinux has three modes, not two:

- **Enforcing** — actively blocks anything policy doesn't allow (the `enforce` equivalent).
- **Permissive** — logs would-be denials but allows the action anyway (the `complain` equivalent).
- **Disabled** — no MAC layer at all.

```bash
getenforce
# Enforcing
```

`setenforce Permissive` / `setenforce Enforcing` toggles between the first two at runtime (switching to or from `Disabled` requires a config change and reboot, not `setenforce`).

### Worked scenario: nginx, a moved content directory, and a 403

Here is the exact trap, worked end to end. An nginx instance has been reconfigured to serve from `/srv/webdata` instead of the default `/var/www/html`. `ls -l` shows perfectly correct ownership and mode bits. Every request still returns `403 Forbidden`.

Step one, confirm this is even in scope for SELinux:

```bash
getenforce
# Enforcing
```

Step two, look past the DAC bits at the actual security context, using `-Z`:

```bash
ls -Z /srv/webdata/index.html
# unconfined_u:object_r:var_t:s0 /srv/webdata/index.html
```

`var_t` is a generic type — it's what a directory outside any conventional path (like `/srv`) inherits by default. It is *not* one of the web-content types (`httpd_sys_content_t` and relatives) that nginx's confined domain has a policy rule to read. That mismatch, not the permission bits, is the entire cause of the 403.

Step three, confirm it in the audit trail:

```bash
sudo ausearch -m avc -ts recent
```

```text
type=AVC msg=audit(...): avc: denied { read } for pid=1234 comm="nginx" name="index.html" scontext=system_u:system_r:httpd_t:s0 tcontext=unconfined_u:object_r:var_t:s0 tclass=file
```

`scontext` is the *process's* domain (`httpd_t`); `tcontext` is the *file's* type (`var_t`). The mismatch between what `httpd_t`'s policy trusts and what this file is actually labeled is the denial, spelled out explicitly.

Step four is where the real exam trap lives. The tempting quick fix:

```bash
sudo chcon -t httpd_sys_content_t /srv/webdata/index.html   # do NOT stop here
```

`chcon` edits a file's live label directly, with **no corresponding entry in SELinux's persistent file-context database**. It "works" immediately and then silently stops working the next time anything triggers a relabel — a policy update, a `restorecon -R /`, anything — because the database, not the file's momentary label, is what the system considers authoritative. The correct, persistent fix is two commands, not one:

```bash
sudo semanage fcontext -a -t httpd_sys_content_t '/srv/webdata(/.*)?'
sudo restorecon -Rv /srv/webdata
```

`semanage fcontext -a` registers a *rule* in the database — "anything under `/srv/webdata` should be labeled `httpd_sys_content_t`" — but touches no files yet. `restorecon -Rv` is the step that actually reads the database and relabels the real files on disk to match, recursively and verbosely. Running `restorecon` again later, or after a full system relabel, is now a safe no-op, because the database itself carries the correct answer. Think of `chcon` as a sticky note stuck directly on the file, and `semanage fcontext` + `restorecon` as updating the actual database of record and then re-printing the file's badge from it — the sticky note falls off the moment anyone reprints badges from the database; the database entry doesn't.

### A second, unrelated mechanism: port-type policy

Suppose this same nginx also needs to listen on TCP `8443`. File context has nothing to do with this — SELinux tracks which ports a process domain is allowed to *bind* through an entirely separate object class, port types:

```bash
sudo semanage port -l | grep http_port_t
# http_port_t   tcp   80, 81, 443, 488, 8008, 8009, 8443, 9000
```

Check before you add — many targeted policies already include `8443` as a conventional alternate-HTTPS port, and `semanage port -a` on a port already assigned to a type simply errors out. If a port genuinely isn't covered yet:

```bash
sudo semanage port -a -t http_port_t -p tcp 8443
```

Config-level changes (nginx's own `listen 8443;` directive) are still separately required — SELinux policy permitting a bind doesn't make nginx attempt one, and nginx attempting one doesn't mean policy allows it. They're independent conditions that both have to be true.

### AppArmor vs. SELinux, side by side

| | AppArmor | SELinux |
|---|---|---|
| Matches on | Literal filesystem **path** | Security **label** (`type`) |
| Distros | Ubuntu, Debian, openSUSE | RHEL, CentOS, Fedora, Rocky |
| Modes | `enforce` / `complain` | `Enforcing` / `Permissive` / `Disabled` |
| Mode-check command | `aa-status` | `getenforce` |
| Denial log | `dmesg` / `journalctl -k`, `apparmor="DENIED"` | `ausearch -m avc`, AVC record |
| Temporary edit tool | — (profile edits are already immediate on reload) | `chcon` (lost on relabel) |
| Persistent fix | Edit profile / `aa-logprof`, then `apparmor_parser -r` | `semanage fcontext -a` + `restorecon` |
| File moved to a new path | Old rule stops matching — profile needs a new rule | Often keeps working — label, not location, decides |

The one-sentence version, worth being able to say out loud on demand: **AppArmor asks "is this exact path listed in this program's profile?"; SELinux asks "what type is this file labeled, and does this process's domain have policy for that type?"** Same category of problem — a second, non-discretionary gate behind DAC — solved by genuinely different matching logic.

---

## Self-Check and Verification

To prove you can diagnose and repair a real path-based MAC denial:

1. Run `aa-status` and identify which profiles are in `enforce` mode versus `complain` mode.
2. Given a `journalctl -k` line containing `apparmor="DENIED"`, identify the `profile=`, `operation=`, and `name=` fields and explain what each one means.
3. Open a profile file under `/etc/apparmor.d/` and identify its path rules versus its `capability` lines.
4. Add a rule permitting access to a new path, either by hand-editing the profile or via `aa-logprof`, and reload it with `apparmor_parser -r`.
5. Confirm the fix by generating a fresh denial-worthy event and checking that it now succeeds — and confirm the profile is genuinely back in `enforce` mode, not left in `complain` mode as a shortcut.
6. Without a VM, talk through the SELinux-equivalent fix for the same kind of scenario: which two commands replace the AppArmor profile edit, and why does `chcon` alone not survive a relabel?

The hands-on half of this checklist is exactly what `labs/lab-041` grades.
