# Part 3 — AppArmor: diagnosing and fixing a path denial

> Prerequisite: [Part 2 — AppArmor: profiles, modes, and what's loaded](./course-02-apparmor-profiles-and-modes.md). Next: [Part 4 — SELinux: labels, contexts, and the AVC denial](./course-04-selinux-labels-and-avc-denials.md).

Part 2 left you with a profile that has no rule for a path the program uses. This part is the full repair loop: read the denial out of the audit log, add exactly the rule it names, reload it into the kernel, and prove the fix is genuine enforcement rather than a masked symptom. This is the graded workflow — the lab checks every step of it.

## Where an AppArmor denial is written

Concrete: the `appservice` daemon has been trying to write `/srv/applogs/app.log` every few seconds since boot, and AppArmor has been refusing every attempt. Each refusal is an **audit event**. AppArmor emits audit events through the kernel's audit subsystem, which lands in the **kernel ring buffer** whether or not the full `auditd` daemon is running. Two ways to read that buffer:

- `dmesg` — the raw ring buffer. Fast, but wraps: on a busy box old messages scroll out.
- `journalctl -k` — the same kernel messages, but journald has already persisted them, so they survive a ring-buffer wraparound and a reboot (with persistent journald). `-k` = `--dmesg` = kernel messages only.

```bash
# shell: playground host, root
sudo journalctl -k | grep 'apparmor="DENIED"'
```

```text
... kernel: audit: type=1400 audit(1757236462.113:78): apparmor="DENIED"
    operation="mknod" profile="/usr/sbin/appservice" name="/srv/applogs/app.log"
    pid=1287 comm="appservice" requested_mask="c" denied_mask="c" fsuid=997 ouid=997
```

## Reading every field

The line is a set of `key=value` pairs; each one narrows the diagnosis:

| Field | What it tells you |
|---|---|
| `apparmor="DENIED"` | AppArmor blocked this (vs `"ALLOWED"` / `"AUDIT"` from a complain-mode or audit rule) |
| `operation="mknod"` | the operation attempted — `mknod` = create the file; `open` = open an existing one; `exec`, `link`, `mkdir`, … |
| `profile="/usr/sbin/appservice"` | **which profile did the denying** — this is the file under `/etc/apparmor.d/` you will edit |
| `name="/srv/applogs/app.log"` | **the literal path** that had no permitting rule — the exact string a rule must now match |
| `requested_mask="c"` / `denied_mask="c"` | the access requested and the part refused: `c` create, `w` write, `r` read, `a` append. `denied_mask` is the gap |
| `comm="appservice"` | the process's command name |
| `pid=1287` | the process instance |
| `fsuid=997 ouid=997` | filesystem uid of the process / owner uid of the target — both `997` here, so **DAC is satisfied**; this is purely MAC |

Notice what is **absent**: no label, no security context, no "type". AppArmor reasoned about one thing — the path string `/srv/applogs/app.log` — against `/usr/sbin/appservice`'s rule list. That is the whole decision. (Part 4's SELinux denial looks completely different: it is all about a pair of contexts and has no meaningful "path had no rule" concept.)

> [!TIP]
> **Try it — read the live denial.** The heartbeat has been failing since boot, so records already exist. On the host:
>
> ```bash
> sudo journalctl -k | grep 'apparmor="DENIED"' | tail -1
> ```
>
> Expect a line like the one above. `operation=` may be `mknod` (first time, file absent) or `open` (file exists), with `requested_mask=` `c` or `w` to match; timestamps, `pid`, and uids vary run to run. The two fields that never change and that drive the fix: `profile="/usr/sbin/appservice"` and `name="/srv/applogs/app.log"`.

## Closing the gap

Two routes. They are not mutually exclusive — `aa-logprof` just automates route A.

### Route A — edit the local override by hand

Add the missing rules to the `local/` file Part 2 pointed out, so a package update to the shipped profile cannot wipe them:

```bash
# shell: host, root
sudo tee -a /etc/apparmor.d/local/usr.sbin.appservice > /dev/null << 'EOF'
/srv/applogs/       r,
/srv/applogs/*.log  rw,
EOF
```

Two rules because the program does two things: it reads the directory (`/srv/applogs/ r,`) and it reads+writes `*.log` files in it (`/srv/applogs/*.log rw,`). Match the `name=` from the denial; if in doubt, a directory rule plus a glob for the files it creates covers a logging service.

Then — the step people forget:

```bash
sudo apparmor_parser -r /etc/apparmor.d/usr.sbin.appservice
```

`apparmor_parser` compiles a profile from text into the kernel's internal form. `-r` = **replace** the currently-loaded version with this one. Editing the file changes only the text on disk; the kernel keeps enforcing the version it last compiled until you replace it. This is the exact analogue of `systemctl daemon-reload` after editing a unit file, or `nginx -s reload` after editing `nginx.conf`. Note you pass the **main** profile path — it pulls in `local/` via the soft include.

> [!TIP]
> **Try it — fix by hand and watch writes land.** Profile in `enforce` mode (from Part 2). On the host:
>
> ```bash
> sudo tee -a /etc/apparmor.d/local/usr.sbin.appservice > /dev/null << 'EOF'
> /srv/applogs/       r,
> /srv/applogs/*.log  rw,
> EOF
> sudo apparmor_parser -r /etc/apparmor.d/usr.sbin.appservice
> sleep 8
> tail -n 3 /srv/applogs/app.log
> sudo journalctl -k --since '15 seconds ago' | grep -c 'apparmor="DENIED".*appservice' || true
> ```
>
> Expect something like:
>
> ```text
> 2026-09-07T09:20:11Z appservice heartbeat pid=1287
> 2026-09-07T09:20:16Z appservice heartbeat pid=1287
> 2026-09-07T09:20:21Z appservice heartbeat pid=1287
> 0
> ```
>
> Fresh heartbeat lines are being written and the new-denial count is `0`. The rule is in `local/`, so a profile package update keeps it. Skip the `apparmor_parser -r` and the file changes but the writes keep failing — the kernel is still on the old compiled profile.

### Route B — let `aa-logprof` propose the rule

```bash
# shell: host, root, interactive
sudo aa-logprof
```

`aa-logprof` — **log** **prof**iling — scans recent AppArmor audit events, and for each denial not already covered it shows the operation and path and offers rule variants (an exact-path rule vs a `*` glob vs a `**` glob), then asks you to **Allow / Deny / adjust** and finally **Save**. It writes your choice into the profile and reloads it for you. It is deliberately semi-interactive: how wide a rule should be is a judgement call — too narrow breaks on the next filename, too wide defeats the confinement — so it will not guess for you. Use it when a program trips many denials at once; a single known gap is faster to fix by hand.

## Proving the fix is real

If any diagnosis step put the profile into `complain`, it must end in `enforce`:

```bash
# shell: host, root
sudo aa-enforce /usr/sbin/appservice
sudo aa-status | grep -A2 'enforce mode' | grep appservice
```

Why this matters: a profile in `complain` also makes the write "succeed" — because nothing is checked. A grader, or a real security review, treats a complain-mode profile as **still broken** even though the symptom is gone. The genuine fix is: rule added, profile reloaded, profile in `enforce`, writes succeeding.

> [!TIP]
> **Try it — tell a real fix from a masked one.** On the host:
>
> ```bash
> sudo aa-complain /usr/sbin/appservice          # nothing is checked now
> sudo journalctl -k --since '10 seconds ago' | grep -c 'DENIED' || true
> sudo aa-enforce /usr/sbin/appservice           # a real gate again
> sudo aa-status | grep -A2 'enforce mode' | grep appservice
> ```
>
> Expect something like:
>
> ```text
> Setting /usr/sbin/appservice to complain mode.
> 0
> Setting /usr/sbin/appservice to enforce mode.
>    /usr/sbin/appservice
> ```
>
> In `complain` the write goes through because *nothing* is enforced — not a fix. Your rule from the previous checkpoint is the fix: back in `enforce`, `aa-status` lists the profile under enforce mode **and** the writes still succeed, because the rule gap is genuinely closed.

> [!WARNING]
> Two mistakes that both look like "it's fixed" when it is not:
> - **Editing the profile and not running `apparmor_parser -r`.** The kernel is still enforcing the previous compile; your write keeps failing and you start doubting a correct rule.
> - **Leaving the profile in `complain` mode.** The write succeeds because MAC is switched off for that program, not because you closed the gap. Always finish with `aa-enforce` and verify with `aa-status`.

> *Read `profile=` and `name=` out of the `apparmor="DENIED"` line, add a matching rule to `/etc/apparmor.d/local/`, run `apparmor_parser -r` on the main profile, and confirm the profile is back in `enforce` — a fix left in `complain` is not a fix.*

## Reference

- `man apparmor_parser` — `-r` (replace), `-R` (remove), `-a` (add), and how it resolves includes.
- `man aa-logprof` and `man aa-genprof` — the semi-interactive profile-building tools and the difference between updating an existing profile and generating a new one.
- `man 8 journalctl` — `-k`, `--since`/`--until`, `-g`/`--grep`, `-p` priority; the flags for slicing an audit trail down to one incident.
