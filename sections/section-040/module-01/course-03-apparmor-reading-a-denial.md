# Read An AppArmor Denial

Astronaut, the `appservice` profile on your playground has no rule for a path the program uses. Before you fix anything, you need proof. This part shows where AppArmor writes its denials, how to pull them out of the log, and what each field of a denial line tells you. The two fields you find here, the profile and the path, are exactly what the fix needs.

## Where an AppArmor denial is written

The `appservice` daemon has tried to write `/srv/applogs/app.log` every few seconds since the ship started. AppArmor has refused every attempt. Each refusal is an **audit event**: the security chief's report about a hatch they kept shut.

The AppArmor module in the kernel sends these events through the kernel's audit system. They land in the **kernel ring buffer**, a fixed-size memory log of kernel messages, even when the full `auditd` daemon is not running. You can read that buffer in two ways:

- `dmesg` reads the raw ring buffer. It is fast, but it wraps around: on a busy machine, old messages scroll out.
- `journalctl -k` shows the same kernel messages through `journald`, the ship's log keeper. `journald` has already stored them, so they survive a ring-buffer wrap, and with a persistent journal they also survive a reboot. `-k` is the same as `--dmesg`: kernel messages only.

<!-- astrona:playground:renew -->

```bash
# shell: playground host, root
sudo journalctl -k | grep 'apparmor="DENIED"'
```

```text
... kernel: audit: type=1400 audit(1757236462.113:78): apparmor="DENIED"
    operation="mknod" profile="/usr/sbin/appservice" name="/srv/applogs/app.log"
    pid=1287 comm="appservice" requested_mask="c" denied_mask="c" fsuid=997 ouid=997
```

This is one real denial line, wrapped here to fit the page. On the machine it is a single long line.

## Reading every field

The denial line is a set of `key=value` pairs. Each one narrows down the problem:

| Field | What it tells you |
|---|---|
| `apparmor="DENIED"` | AppArmor blocked this (other values are `"ALLOWED"` or `"AUDIT"`, from a complain-mode profile or an audit rule) |
| `operation="mknod"` | what was attempted: `mknod` = create the file; `open` = open a file that exists; also `exec`, `link`, `mkdir` and more |
| `profile="/usr/sbin/appservice"` | **which profile said no**. This tells you which file under `/etc/apparmor.d/` to change |
| `name="/srv/applogs/app.log"` | **the exact path** that had no rule allowing it. A new rule must match this string |
| `requested_mask="c"` / `denied_mask="c"` | the access asked for, and the part refused: `c` create, `w` write, `r` read, `a` append. `denied_mask` is the gap |
| `comm="appservice"` | the command name of the process |
| `pid=1287` | the process number of this one run |
| `fsuid=997 ouid=997` | the user id the process used for file access, and the owner id of the target. Both are `997` here, so **DAC is happy**. This is MAC alone |

Notice what is **missing**: no label, no security context, no "type". AppArmor looked at one thing only: the path string `/srv/applogs/app.log`, checked against the rule list of `/usr/sbin/appservice`. That was the whole decision. An SELinux denial looks completely different: it is about a pair of labels, and it has no "this path had no rule" idea at all.

### Read the live denial in your playground

The daemon has failed to write since the playground started, so denial records already exist. Show the latest one:

```bash
sudo journalctl -k | grep 'apparmor="DENIED"' | tail -1
```

You see a line like the one above. `operation=` may be `mknod` (the file does not exist yet) or `open` (the file exists), with `requested_mask=` `c` or `w` to match. The time stamp, `pid` and user ids change from run to run. The two fields that never change, and that drive the fix, are `profile="/usr/sbin/appservice"` and `name="/srv/applogs/app.log"`.

> [!TIP]
> Copy the `name=` value straight out of the denial line into your rule. Typing a path from memory is how a rule ends up one letter off and matching nothing.

## Common pitfalls

> [!WARNING]
> - **Reading only `dmesg` on a busy machine.** The ring buffer wraps, and the denial you need may already be gone. `journalctl -k` keeps it.
> - **Looking for a label in an AppArmor line.** There is none. The `profile=` and `name=` fields are all the decision used.
> - **Ignoring the mask.** `denied_mask` says which access was refused (`c`, `w`, `r`, `a`). A rule that grants the wrong access leaves the gap open.
> - **Blaming DAC when `fsuid` and `ouid` match.** If the process's user id and the file owner's id are the same and the line says `apparmor="DENIED"`, the permissions are not the problem.

> *An AppArmor denial is an `apparmor="DENIED"` line in the kernel log. Read it with `journalctl -k`, then take `profile=` (which profile to change), `name=` (the exact path) and `denied_mask=` (which access) from it.*
