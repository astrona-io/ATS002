# Fix An AppArmor Denial And Prove It

You know which profile said no and which path it refused. Now you close the gap. This part is the full repair loop: add exactly the rule the denial names, load the changed profile into the kernel, and prove the fix is real enforcement and not a hidden symptom. The graded missions check every step of this loop.

## Closing the gap

There are two ways to add the missing rule. They do the same job: `aa-logprof` simply automates the hand edit.

### Route A: edit the local file by hand

Put the missing rules in the profile's `local/` file. A package update can replace the main profile, but it leaves the `local/` file alone, so your rules survive. On your playground that file already exists and holds only one comment line.

<!-- astrona:playground:renew -->

Save this as `/etc/apparmor.d/local/usr.sbin.appservice` (for example with `sudo nano`):

```text
# Site-specific additions and overrides for usr.sbin.appservice go here.
/srv/applogs/       r,
/srv/applogs/*.log  rw,
```

You add two rules because the program does two things. It reads the directory (`/srv/applogs/ r,`), and it reads and writes `*.log` files inside it (`/srv/applogs/*.log rw,`). Match the `name=` from the denial. For a logging service, a rule for the directory plus a wildcard for the files it creates is usually enough.

Apply it:

```sh
sudo apparmor_parser -r /etc/apparmor.d/usr.sbin.appservice
```

This is the step people forget. `apparmor_parser` turns a profile from text into the kernel's own form and loads it. `-r` means **replace**: swap the version the kernel has now for this one. Editing the file only changes the text on disk. The AppArmor module in the kernel keeps using the version it last loaded until you replace it. It is the same idea as `systemctl daemon-reload` after you edit a unit file. Note that you pass the **main** profile path: it pulls in the `local/` file through the soft include.

Then check the result:

```sh
sleep 8
tail -n 3 /srv/applogs/app.log
sudo journalctl -k --since '15 seconds ago' | grep -c 'apparmor="DENIED".*appservice' || true
```

You see something like:

```text
2026-09-07T09:20:11Z appservice heartbeat pid=1287
2026-09-07T09:20:16Z appservice heartbeat pid=1287
2026-09-07T09:20:21Z appservice heartbeat pid=1287
0
```

New heartbeat lines are being written, and the count of new denials is `0`. The rule lives in `local/`, so a package update keeps it. If you skip `apparmor_parser -r`, the file changes but the writes keep failing, because the kernel still runs the old profile.

### Route B: let `aa-logprof` suggest the rule

```bash
# shell: host, root, interactive
sudo aa-logprof
```

`aa-logprof` (**log prof**iling) reads recent AppArmor audit events. For each denial no rule covers yet, it shows the operation and the path. It then offers rule choices: the exact path, a `*` wildcard or a `**` wildcard. You answer **Allow**, **Deny** or adjust the rule, and finally **Save**. It writes your choice into the profile and reloads it for you.

It asks instead of guessing on purpose. How wide a rule should be is a judgement call: too narrow breaks on the next file name, too wide defeats the point of the profile. Use `aa-logprof` when a program trips many denials at once. One known gap is faster to fix by hand. The manual pages `man aa-logprof` and `man aa-genprof` on the ship explain the difference between updating a profile and building a new one.

## Proving the fix is real

A fix only counts if the profile still blocks everything else. If you put the profile into complain mode at any point while you looked for the problem, it must end in enforce mode:

```bash
# shell: host, root
sudo aa-enforce /usr/sbin/appservice
sudo aa-status | grep -A2 'enforce mode' | grep appservice
```

Here is why this matters. A profile in complain mode also makes the write "work", because nothing is checked. A grader, or a real security review, treats a complain-mode profile as **still broken**, even though the error is gone. The real fix is all four together: rule added, profile reloaded, profile in enforce mode, writes working.

### Tell a real fix from a hidden one

Try both states on your playground:

```bash
sudo aa-complain /usr/sbin/appservice          # nothing is checked now
sudo journalctl -k --since '10 seconds ago' | grep -c 'DENIED' || true
sudo aa-enforce /usr/sbin/appservice           # a real gate again
sudo aa-status | grep -A2 'enforce mode' | grep appservice
```

You see something like:

```text
Setting /usr/sbin/appservice to complain mode.
0
Setting /usr/sbin/appservice to enforce mode.
   /usr/sbin/appservice
```

In complain mode the write goes through because *nothing* is enforced. That is not a fix. Your rule is the fix: back in enforce mode, `aa-status` lists the profile under enforce mode **and** the writes still work, because the gap is really closed.

## Common pitfalls

> [!WARNING]
> Two mistakes look like "it is fixed" when it is not:
> - **Editing the profile and not running `apparmor_parser -r`.** The kernel still uses the old profile. Your write keeps failing, and you start to doubt a correct rule.
> - **Leaving the profile in complain mode.** The write works because MAC is switched off for that program, not because you closed the gap. Always finish with `aa-enforce` and check with `aa-status`.
>
> And one more:
> - **Passing the `local/` file to `apparmor_parser`.** Reload the main profile, `/etc/apparmor.d/usr.sbin.appservice`. It pulls in the `local/` file itself.

> *Take `profile=` and `name=` from the `apparmor="DENIED"` line, add a matching rule to `/etc/apparmor.d/local/`, run `apparmor_parser -r` on the main profile, and confirm the profile is back in enforce mode. A fix left in complain mode is not a fix.*

## Your mission: AppArmor Profile Enforcement Lab

You can now read a denial, add the rule it names, reload the profile and prove it still enforces. The mission asks you to repair a service whose profile blocks a write to its new log directory, and to leave the profile enforcing.

The mission runs on its own training ship. Your playground cannot be paused, so remove it first. It always starts clean, so you lose nothing you need:

```sh
astrona destroy apparmor-mac-enforcement
```

Then start the mission and open a terminal on it:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-040/module-01/labs/lab-01
astrona ssh ats-002-lab-041
```

Read the task in [`question.md`](./labs/lab-01/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-040/module-01/labs/lab-01
```

When the mission is done, remove it and start your playground again:

```sh
astrona destroy ats-002-lab-041
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-040/module-01/playground
```

## Your mission: AppArmor: Repair a Read Denial Lab

You can now close a denial in any direction, not only a write. The mission asks you to repair a daemon whose profile blocks it from **reading** its key file, with the profile still enforcing at the end.

The mission runs on its own training ship. Your playground cannot be paused, so remove it first. It always starts clean, so you lose nothing you need:

```sh
astrona destroy apparmor-mac-enforcement
```

Then start the mission and open a terminal on it:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-040/module-01/labs/lab-02
astrona ssh ats-002-lab-042
```

Read the task in [`question.md`](./labs/lab-02/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-040/module-01/labs/lab-02
```

When the mission is done, remove it and start your playground again:

```sh
astrona destroy ats-002-lab-042
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-040/module-01/playground
```
