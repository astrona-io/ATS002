# Wrap-Up: Mission Debrief

Well flown, astronaut. You have finished every part and every mission in this module. Before you move on, look back at what you learned, check yourself, and land the playground cleanly.

## What you learned

This module was about one job: finding out why a service will not start, fixing it, and proving the fix, with `systemctl` and `journalctl`.

**From [The Service Manager And Unit State](./course-01-service-manager-and-unit-state.md):**

- `systemctl` is only a client. `systemd`, running as PID 1, starts, watches and records every service.
- Every unit is in one `ActiveState`: `inactive`, `activating`, `active`, `deactivating` or `failed`. A `failed` unit stays failed until it is started again or cleared with `reset-failed`.
- The `Result` tag (`exit-code`, `timeout`, `signal`, `core-dump`, `oom-kill`, `resources`) says which kind of failure to chase.
- The lines under `systemctl status` are only a short tail of the log.
- `is-active`, `is-enabled` and `is-failed` print one word each; `systemctl --failed` lists every failed unit.

**From [The Effective Unit Definition](./course-02-the-effective-unit-definition.md):**

- Unit files are searched in `/etc/systemd/system/`, then `/run/systemd/system/`, then `/usr/lib/systemd/system/`. The administrator's folder wins.
- Drop-ins in `<unit>.d/*.conf` change single lines; the last sorted file name wins.
- List settings such as `ExecStart=` need an empty `ExecStart=` line before the new value.
- `systemctl cat` shows every file; `systemctl show -p` shows the computed values.
- `daemon-reload` makes the manager read the unit files again. It does not restart anything.

**From [Reading The Journal](./course-03-reading-the-journal.md):**

- The journal stores fields, not lines. Fields that start with `_` are set by `journald` and cannot be faked.
- `journalctl -u` joins the service's own lines with PID 1's lines about the unit.
- `-b`, `--since`, `-p`, `-g` and `-k` cut the journal down to one incident; `-xeu` is the usual start.
- In a chain of errors, the first real error is the cause, and `Failed to start` at the bottom is the least useful line.

**From [Keeping The Journal](./course-04-keeping-the-journal.md):**

- `Storage=auto` keeps the journal on disk only if `/var/log/journal/` exists; otherwise it lives in `/run` and is lost at reboot.
- An empty `journalctl -b -1` can mean "not kept", not "no errors".
- `SystemMaxUse=` caps the journal's disk use; `journald` reads its settings when `systemd-journald` restarts.

**From [Bad Commands And Taken Ports](./course-05-bad-commands-and-taken-ports.md):**

- A start job runs `ExecStartPre=`, then `ExecStart=`, then waits for "ready" as defined by `Type=`.
- A program that rejects its configuration shows its own error and `Result: exit-code`; check it with tools such as `apache2ctl configtest` and `systemd-analyze verify`.
- `status=203/EXEC` means `systemd` could not run the `ExecStart=` program at all.
- `(98)Address already in use` means another program holds the port; `ss -ltnp` names it.

**From [Dependencies, Permissions And Restart Loops](./course-06-dependencies-permissions-and-restart-loops.md):**

- `Requires=` passes failure along: a broken dependency pulls the dependent unit down.
- A missing readiness signal ends in `Result: timeout` after `TimeoutStartSec=`.
- `Permission denied`: check file permissions and the unit's `User=`, then the unit's sandbox, then AppArmor or SELinux denials in `journalctl -k`.
- A restart loop ends in `start-limit-hit`; fix the real cause, then `reset-failed`.

**From [Proving The Fix And Boot Targets](./course-07-proving-the-fix-and-boot-targets.md):**

- Restart after a configuration change; `daemon-reload` and restart after a unit change.
- Prove the fix with `is-active`, `status` and `journalctl -u`.
- `active` (running now) and `enabled` (starts at boot) are separate; `enable --now` sets both.
- The default boot target is a symlink; `get-default` reads it and `set-default` changes it for the next boot.

## Your missions

You proved each skill in a graded mission, right after the part that taught it:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [Configure journald: Persistent & Bounded Lab](./labs/lab-05/README.md) | Keeping The Journal | make the journal survive reboots and cap its size |
| [Service Won't Start: Bad ExecStart Path Lab](./labs/lab-01/README.md) | Bad Commands And Taken Ports | fix a `203/EXEC` start failure and keep the service enabled |
| [Service Won't Start: Port Already In Use Lab](./labs/lab-03/README.md) | Bad Commands And Taken Ports | find the program holding a port and get the right service listening |
| [Service Won't Start: Permission Denied Lab](./labs/lab-02/README.md) | Dependencies, Permissions And Restart Loops | fix a write permission problem while staying non-root |
| [Service Won't Start: Failed Dependency & Restart Flap Lab](./labs/lab-04/README.md) | Dependencies, Permissions And Restart Loops | repair a broken dependency, clear `start-limit-hit` and enable both units |
| [Set the Default Boot Target Lab](./labs/lab-06/README.md) | Proving The Fix And Boot Targets | change the target the machine boots into |

If you skipped one, go back to it now. Each mission is short, and the exam asks for exactly these skills.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. <code>systemctl status</code> shows <code>Loaded: not-found</code>. What do you check first?</summary>

The unit name. The manager found no unit file with that name, so nothing else in the report matters yet.
</details>

<details>
<summary>2. You edited <code>/etc/systemd/system/reportd.service</code> and ran <code>systemctl restart reportd</code>, but nothing changed. Why?</summary>

You skipped `daemon-reload`. The manager still holds the old version of the unit in memory. Run `sudo systemctl daemon-reload`, then restart.
</details>

<details>
<summary>3. A drop-in contains only <code>ExecStart=/usr/local/bin/new</code>. What goes wrong?</summary>

`ExecStart=` is a list, so the line adds a second start command instead of replacing the first. Put an empty `ExecStart=` line before the new one.
</details>

<details>
<summary>4. <code>journalctl -b -1</code> shows nothing. Was the previous boot clean?</summary>

Not necessarily. With `Storage=auto` and no `/var/log/journal/` folder, the journal lives only in memory and is lost at reboot. Check `Storage=` and the folder first.
</details>

<details>
<summary>5. The <code>Process:</code> line says <code>status=203/EXEC</code>. What does that mean?</summary>

`systemd` could not run the `ExecStart=` program at all, for example because the path is wrong. The program never ran, so this is not its own exit code.
</details>

<details>
<summary>6. The journal shows <code>(98)Address already in use</code>. Which command names the culprit?</summary>

`sudo ss -ltnp 'sport = :<port>'`. The `-p` option shows the process that holds the port.
</details>

<details>
<summary>7. A unit shows <code>start-limit-hit</code>. You fixed the real fault. Why does <code>systemctl start</code> still refuse?</summary>

The start limit stays latched. Run `sudo systemctl reset-failed <unit>`, then start it again.
</details>

<details>
<summary>8. A task says "running and starts on boot". Which two checks prove it?</summary>

`systemctl is-active <unit>` must print `active`, and `systemctl is-enabled <unit>` must print `enabled`. `enable --now` sets both.
</details>

## Clean up the playground

Your playground is a whole virtual machine running on your computer. When you are done with this module, remove it, and any mission that is still running.

First, see what is still running:

```sh
astrona list
```

Remove the playground. The command takes its **name**, not its folder path:

```sh
astrona destroy systemd-service-debugging
```

If `astrona list` also showed a mission, remove it the same way, for example:

```sh
astrona destroy ats-002-lab-016
```

Then check that everything is gone:

```sh
astrona list
```

```text
No astrona labs running.
```

You can start the playground again at any time with the `astrona run` command from the module's landing page. It always starts clean, so nothing you broke carries over.

> *Read the verdict with `systemctl status`, the evidence with `journalctl -u`, fix the first real error, and prove the fix with `is-active` and `is-enabled`.*
