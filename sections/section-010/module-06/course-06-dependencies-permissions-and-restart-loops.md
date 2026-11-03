# Dependencies, Permissions And Restart Loops

Some services fail even though their own start command and configuration are fine. The cause sits next to them: a station they depend on is down, the service may not open a file it needs, or `systemd` has simply given up restarting it. This part covers those failures. Each has its own fingerprint, and in each one the line that looks most alarming is often not the cause.

## Kind 3: a dependency failed, or readiness timed out

This kind of failure shows no error from the program itself. The journal shows `Failed to start`, `Dependency failed for …` or `Result: timeout` instead. There are two cases, and both come from the way `systemd` waits for other stations and for "ready".

### A required station is down

`Requires=` and `After=` together say "this station needs that one staffed first". `Requires=` also passes failure along. If `apache2.service` requires `mysql.service` and MySQL fails, `systemd` pulls `apache2` down with it, and the journal shows `Dependency failed for` the dependent unit. `After=` alone only sets the start order. It does not pass failure along.

### Readiness never came

A `Type=notify` service that never sends `READY=1`, or a `Type=forking` service whose first process never exits, stays in `activating`. When `TimeoutStartSec=` runs out (90 seconds by default), the manager kills it and records `Result: timeout`.

### Check the dependencies and the timing

Two commands show the dependency tree and the timing settings of a unit:

<!-- astrona:playground:renew -->

```bash
systemctl list-dependencies --failed apache2   # any failed unit in the tree?
systemctl show apache2 -p Type -p TimeoutStartUSec -p Requires -p After
```

Fix the unit it depends on first. If the service starts its work in a different way than its `Type=` says, correct `Type=` with a drop-in. The manual page `man systemd.unit` explains `Requires=`, `Wants=` and `After=`.

## Kind 4: permission, path or mandatory access control

Here the service runs, or tries to, but is not allowed to reach a file or folder it needs. There are several locks between a service and a file, and this section checks them in order.

### The fingerprint

The program starts and then gets `EACCES`, `Permission denied` or `Read-only file system` on a path. It logs the error and exits, so `systemctl status` shows `Result: exit-code` and the journal shows the program's own `Permission denied` line. If `systemd` cannot even set the process up (for example the user named in `User=` does not exist), the program never runs, and the `Process:` line shows a special status from `systemd` in the 200 range instead of the program's own exit code.

### Three locks to check, in order

1. **Ordinary file permissions.** File permissions (sometimes called DAC, discretionary access control) are the lock on each hatch: the owner of the crate decides who gets a key. Check which user the service runs as with `systemctl show -p User <unit>`, and who owns the path with `ls -ld <path>`. A service that runs as a non-root user needs that user to have access. The manual page `man systemd.exec` describes `User=` and settings such as `StateDirectory=`, which tells `systemd` to create a folder under `/var/lib` owned by the service's user.
2. **The unit's own sandbox.** Settings such as `ProtectSystem=strict`, `ProtectHome=`, `ReadOnlyPaths=`, `ReadWritePaths=` and `PrivateTmp=` make parts of the file system hidden or read-only *for that one service*. Check them with `systemctl show apache2 | grep -E 'Protect|ReadWrite|ReadOnly|PrivateTmp'`. A path the service must write to has to be listed in `ReadWritePaths=`.
3. **Mandatory access control (MAC).** This is the ship's security chief: a second check that overrides the owner's keys. If `ls -l` looks right and access is still denied, look in the kernel log for a denial from the security module:

   ```bash
   sudo journalctl -k | grep -E 'apparmor="DENIED"|avc:  denied'
   ```

   `apparmor="DENIED"` comes from AppArmor, the security module on Ubuntu. `avc:  denied` comes from SELinux on Red Hat family systems. The fix is then in the AppArmor profile (or the SELinux label of the file), not in the unit: the profile has no rule for the path the service now uses.

## The restart loop and `start-limit-hit`

A unit with `Restart=always` or `Restart=on-failure` and a start command that fails fast does not fail just once. It **flaps**: `activating (auto-restart)`, then `failed`, then `activating` again, and so on. This section shows how the loop ends and how to clear it.

### When the duty officer gives up

The loop goes on until it hits the rate limit: `StartLimitBurst=` attempts (5 by default) within `StartLimitIntervalSec=` (10 seconds by default). Then the duty officer gives up after too many failed attempts in a row:

```text
apache2.service: Start request repeated too quickly.
apache2.service: Failed with result 'start-limit-hit'.
```

`start-limit-hit` is not the cause. It is only the manager giving up. Find the real failure in the journal lines from *before* the loop started, and fix it.

### Clear the latch and start again

The `start-limit-hit` state stays until you clear it. After the real fix, reset it and start the unit:

```bash
sudo systemctl reset-failed apache2
sudo systemctl start apache2
```

`reset-failed` clears the failed state and the counter of start attempts, so the manager will try the unit again.

## Common pitfalls

> [!WARNING]
> - **Fixing the unit that shows the error instead of the one it depends on.** With `Requires=`, a broken dependency pulls the dependent unit down too. Check `systemctl list-dependencies` and fix the unit at the bottom of the chain first.
> - **Thinking `Requires=` enables the other unit.** It couples the two at run time. Each unit still needs its own `enable` to start at boot.
> - **Fixing a permission problem by running the service as `root`.** That removes a safety lock. Give the service's own user access to the path instead.
> - **Fixing a restart loop without `reset-failed`.** `start-limit-hit` stays until you clear it, even after the real fault is gone.
> - **Treating `start-limit-hit` as the cause.** It is only the manager giving up. The real error is earlier in the journal.

> *A failed dependency or a missing readiness signal shows `Dependency failed` or `Result: timeout`. A permission problem shows `Permission denied`; check file permissions, the unit's sandbox and then mandatory access control. A restart loop ends in `start-limit-hit`, which `reset-failed` clears once the real fault is fixed.*

## Your mission: Service Won't Start: Permission Denied Lab

You can now trace a `Permission denied` failure to the user a service runs as and the path it needs. The mission gives you a service that cannot write to its own data folder, and asks you to fix the access problem while the service keeps running as a non-root user.

The mission runs on its own training ship. Your playground cannot be paused, so remove it first. It always starts clean, so you lose nothing you need:

```sh
astrona destroy systemd-service-debugging
```

Then start the mission and open a terminal on it:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/module-06/labs/lab-02
astrona ssh ats-002-lab-017
```

Read the task in [`question.md`](./labs/lab-02/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-010/module-06/labs/lab-02
```

When the mission is done, remove it and start your playground again:

```sh
astrona destroy ats-002-lab-017
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/module-06/playground
```

## Your mission: Service Won't Start: Failed Dependency & Restart Flap Lab

You can now follow a failure down a `Requires=` chain and clear a `start-limit-hit` state. The mission gives you a worker service that is pulled down by a broken service it depends on and has hit its restart limit, and asks you to get both running and enabled for boot.

The mission runs on its own training ship. Your playground cannot be paused, so remove it first. It always starts clean, so you lose nothing you need:

```sh
astrona destroy systemd-service-debugging
```

Then start the mission and open a terminal on it:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/module-06/labs/lab-04
astrona ssh ats-002-lab-019
```

Read the task in [`question.md`](./labs/lab-04/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-010/module-06/labs/lab-04
```

When the mission is done, remove it and start your playground again:

```sh
astrona destroy ats-002-lab-019
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/module-06/playground
```
