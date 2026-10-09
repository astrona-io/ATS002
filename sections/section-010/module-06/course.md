# Debugging A Service That Will Not Start

Astronaut, someone on the bridge tells you "the web server is down". You run `systemctl start apache2`, the console pauses, and it answers `Job for apache2.service failed`. No clear reason, no obvious cause. But nothing here is a mystery. `systemd`, the ship's duty officer, ran the service, watched it fail, recorded the exit code and kept every line the process wrote on its way down. All of it is already on the machine. This module teaches you to read that record in the right order instead of guessing at configuration files.

Two tools do the work, and they sit at different layers. `systemctl` (system control) asks `systemd` what **state** a unit is in and why. `journalctl` (journal control) reads the **journal**, the ship's log of everything every service printed, plus the duty officer's own notes about starting and stopping them. Keep this contrast in mind: `systemctl status` is the verdict, a short summary; `journalctl -u` is the full evidence. Read the verdict, then the evidence, and only then change a file.

## Learning objectives

After this module you can:

- Name the state a unit is stuck in from `systemctl status`, and read `Loaded:`, `Active:`, `Result:`, `Process:` and `Main PID:` correctly.
- Choose between `systemctl status` (for people), the one-word `is-*` checks (for scripts) and `systemctl --failed` (for the whole machine).
- Show a unit's effective definition with `systemctl cat` and `systemctl show -p`, and explain why reading the vendor file alone is not enough.
- Explain what `systemctl daemon-reload` does, and how it differs from `systemctl reload` and from `restart`.
- Search the journal for one unit and one incident with `journalctl -u`, `-b`, `--since`, `-p`, `-g` and `-xeu`, and read a chain of errors to its first real error.
- Make the journal survive a reboot and cap its size.
- Tell the kinds of start failure apart from their fingerprints (bad configuration or start command, port in use, dependency or readiness, permission or mandatory access control), and name the tool for each (`apache2ctl -t`, `ss -ltnp`, `list-dependencies`, `journalctl -k`).
- Prove a fix with `is-active`, `status` and `journalctl`, use `enable --now` so the service also survives a reboot, and set the default boot target.

## Before you start

Check that you have the knowledge this module expects, and know what is waiting in your playground.

### What you should already know

- **A Linux shell and `sudo`.** You can type commands, read their output and run a command as root.
- **Editing a text file.** You can open and change a configuration file with an editor such as `nano` or `vim`.
- **What a service is.** A service is a program that runs in the background, such as a web server. On this machine, `systemd` starts and manages every service.

### What is in your playground

Your playground is a training ship: one Ubuntu 24.04 virtual machine where **`apache2` has already failed**. A small helper unit, `port80-hog.service`, holds port 80 with a `socat` listener, so Apache cannot listen there. That gives you a real failed unit with a real trail in the journal, plus `ss` to see who holds the port.

Start the playground with `astrona run`, then open a terminal on it with `astrona ssh astro-systemd-service-debugging`. Every "See it in your playground" step in the parts runs there. When you are done, remove it with `astrona destroy systemd-service-debugging`. Launch it now and keep it running next to you while you read:

<!-- astrona:playground -->

## How this module is laid out

1. [The Service Manager And Unit State](./course-01-service-manager-and-unit-state.md): `systemctl` as a client of PID 1, the unit states, the `Result:` categories, reading `systemctl status` line by line, and the `is-*` checks.
2. [The Effective Unit Definition](./course-02-the-effective-unit-definition.md): the unit load path, drop-in files and how they merge, `systemctl cat` and `show -p`, `systemctl edit`, and what `daemon-reload` really does.
3. [Reading The Journal](./course-03-reading-the-journal.md): the journal as fields, what `-u` matches, cutting the log down to one incident, and reading a chain of errors first error first.
4. [Keeping The Journal](./course-04-keeping-the-journal.md): `Storage=`, why the previous boot can be missing, making the journal persistent and capping its size.
   - Mission: Configure journald: Persistent & Bounded Lab
5. [Bad Commands And Taken Ports](./course-05-bad-commands-and-taken-ports.md): how a start job runs, a bad configuration or `ExecStart=` path, and a port that is already in use.
   - Mission: Service Won't Start: Bad ExecStart Path Lab
   - Mission: Service Won't Start: Port Already In Use Lab
6. [Dependencies, Permissions And Restart Loops](./course-06-dependencies-permissions-and-restart-loops.md): `Requires=` failures, readiness timeouts, permission and mandatory access control denials, and `start-limit-hit`.
   - Mission: Service Won't Start: Permission Denied Lab
   - Mission: Service Won't Start: Failed Dependency & Restart Flap Lab
7. [Proving The Fix And Boot Targets](./course-07-proving-the-fix-and-boot-targets.md): applying and proving a fix, `active` versus `enabled`, and the default boot target.
   - Mission: Set the Default Boot Target Lab
8. [Wrap-Up: Mission Debrief](./course-08-wrap-up.md)

## Why this matters

A service that will not start is one of the most common problems on a real server, and one of the most common tasks on the exam. The exam does not check what you typed; it checks the machine's real state, often after a reboot. Reading `systemctl status` and `journalctl -u` in the right order tells you the exact cause before you touch a file, and `is-active` plus `is-enabled` prove that your fix holds.
