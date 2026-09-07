# Chapter 6: Debugging a Service That Won't Start with systemctl and journalctl

Someone tells you "the web server is down." You run `systemctl start apache2`, the shell pauses, and hands back `Job for apache2.service failed`. No stack trace, no obvious cause. But nothing here is mysterious: `systemd` ran the service, watched it fail, recorded the exit code, and captured every line the process wrote on its way down. All of it is already on the machine. This module is about reading that record in the right order instead of guessing at config files.

Two tools do the work, and they sit at different layers. `systemctl` — *system control* — is a client of `systemd` running as PID 1; it reports what **state** a unit is in and why. `journalctl` — *journal control* — queries the **journal**, the structured store of everything every unit printed plus PID 1's own messages about starting and stopping them. The contrast to keep in mind: `systemctl status` is the verdict (ten lines, already summarised); `journalctl -u` is the full evidence. Read the verdict, then the evidence, then change a file — in that order.

The module is split into four parts; work them in order — each uses terms the earlier ones define.

## How this module is organised

1. **[Part 1 — The service manager and unit state](./course-01-service-manager-and-unit-state.md)** — `systemctl` as a client of PID 1, the unit lifecycle state machine (`inactive → activating → active`, the `failed` sink), the `Result:` failure categories, reading `systemctl status` field by field, and `is-active` / `is-enabled` / `is-failed` / `--failed`.
2. **[Part 2 — The effective unit definition](./course-02-the-effective-unit-definition.md)** — the unit load path and its precedence, drop-in `.d/*.conf` merging (and the list-directive reset idiom), `systemctl cat` vs `show -p`, `systemctl edit`, and what `daemon-reload` actually re-parses.
3. **[Part 3 — Reading the journal](./course-03-reading-the-journal.md)** — the journal as a store of fields not lines, what `-u` really matches, slicing by boot / time / priority / grep, `Storage=` and why the previous boot can be missing, and reading a failure cascade first-error-first.
4. **[Part 4 — Failure shapes, and proving the fix](./course-04-failure-shapes-and-proving-the-fix.md)** — the four shapes a start-failure takes as consequences of the start job (bad config, port in use, dependency/readiness timeout, permission/MAC), the `Restart=` flap, the verify loop, and why `active` and `enabled` are separate checks.

## Learning objectives

After this module you can:

- **Name** the state a unit is stuck in from `systemctl status`, and read `Loaded:`, `Active:`, `Result:`, and `Process:` / `Main PID:` correctly.
- **Choose** between `systemctl status` (human triage), the `is-*` one-word checks (scripting), and `systemctl --failed` (whole-system).
- **Show** a unit's effective definition with `systemctl cat` and `systemctl show -p`, and explain why reading the vendor file alone is not enough.
- **Explain** what `systemctl daemon-reload` does, and distinguish it from `systemctl reload` and from `restart`.
- **Query** the journal for one unit and one incident — `journalctl -u`, `-b`, `--since`, `-p`, `-g`, `-xeu` — and read a failure cascade to its first concrete error.
- **Diagnose** which of the four start-failure shapes applies from the `status` / journal signature, and name the tool for each (`apache2ctl -t`, `ss -ltnp`, `list-dependencies`, `journalctl -k`).
- **Verify** a fix with `is-active` + `status` + `journalctl`, and set `enable --now` so the service also survives a reboot.

## Before you start

Assumed: comfort with a Linux shell and `sudo`, editing a text config file, and the idea that `systemd` manages long-running services. Chapter 5 (`strace`) is useful adjacent context — it diagnoses a *running* process; this module diagnoses one that will not start or stay started — but it is not a prerequisite.

There is no dedicated playground for this module yet. Every command block states the shell and privilege it assumes; run them against any `systemd` host with a service you can safely stop and start (`apache2` on Debian/Ubuntu, `httpd` on RHEL-family). A graded lab — `apache2` rigged to fail one of the four ways — is planned at `labs/section-010/module-06/lab-01`.

## Where this fits

Chapters 1–5 built the live-diagnosis toolkit for a machine mid-incident: read kernel state precisely, reason about the ceilings on process creation, manage which modules the kernel runs, give devices stable names, and trace a running process. This module adds the service-manager view — when the thing misbehaving is a `systemd` unit that will not come up, `systemctl status` and `journalctl -u` tell you exactly why before you touch a config file. It is one of the most frequently tested shapes on the LFCS "Operation of Running Systems" domain, and it feeds the section capstone, which stages a multi-fault incident that includes a service that will not start.
