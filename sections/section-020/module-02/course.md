# Docker Container Lifecycle: Inspect, Stop, and Launch

Working with a container comes down to three skills: knowing which state it is in and how each verb moves it, stopping the process inside cleanly instead of just killing it, and pulling one precise fact out of the daemon's record instead of reading a wall of JSON. This module covers the lifecycle state machine, `docker stop` versus `docker kill`, the `docker inspect --format` template language, and launching a container with a verified resource ceiling.

Two short parts; work them in order.

## How this module is organised

1. **[Part 1 — The container lifecycle, and stopping one cleanly](./course-01-the-container-lifecycle-and-stopping.md)** — the created / running / paused / exited / dead state machine, why `docker stop` leaves a container `exited` rather than removed, the `SIGTERM` → grace period → `SIGKILL` mechanism, PID 1 signal handling, and when `docker kill` is the right call.
2. **[Part 2 — Inspecting with `--format`, and launching with constraints](./course-02-inspecting-with-format.md)** — `docker inspect` as the daemon's full JSON record (create-time `.Config` vs runtime state), the Go-template language (`range`, `index`, `len`), per-network IP addresses, `docker run` with `--memory` and `-p`, and verifying limits from the daemon's record.

## Learning objectives

After this module you can:

- **Name** the container states and the verb that causes each transition, and explain why `stop` ≠ `rm`.
- **Explain** what `docker stop` does signal by signal, and why a shell-form `CMD` makes it wait the full grace period.
- **Choose** between `docker stop` and `docker kill`, and adjust the grace period with `-t`.
- **Write** `docker inspect --format` templates using field paths, `range`, and `index`.
- **Extract** a container's IP address whether it is on the default bridge or a user-defined network.
- **Launch** a detached container with a memory limit and a port mapping, getting the `-p` direction right.
- **Verify** the applied memory limit (in bytes) and port mapping from `docker inspect` / `docker ps`, not from the command you typed.

## Before you start

Assumed: a Linux shell, the idea of a container as an isolated process, and basic JSON. Section 010's signal material (`SIGTERM` / `SIGKILL`) is useful background. Every command block states the context it assumes and runs against any Docker daemon you can reach (add `sudo` if your user is not in the `docker` group).

## Where this fits

This module is the "in what environment does it run" half of the section — cron (Module 1) schedules *who* runs a job, containers bound *how* it runs. The section capstone recovers a scheduled containerised workload, so carry forward both the "stop is not remove" distinction and the habit of verifying container config from the daemon's record.
