# Section 020: Scheduled & Containerized Workloads

Astronaut, setting up a server once is easy. Keeping it running correctly, night after night, with nobody at the console, is the real job. This section covers the tools you will use for that every day: scheduled jobs that start on their own, and containers you can start, stop, inspect and limit.

Both topics look simple from the outside: "just add a line to a file" and "just run a container". Both hide sharp edges. Cron has two places to define a job, and the wrong one runs the job as the wrong account or runs it twice. A container's record is a wall of JSON, and pulling one fact out of it quickly, under time pressure, is a skill of its own.

## What you will learn

By the end of this section you can:

- **Schedule jobs per user.** Tell the system-wide cron files from per-user crontabs, move a job between them without running it twice, and write schedules such as "Monday and Thursday at 11:15".
- **Read a container's record.** Use `docker inspect --format` to pull one exact fact, such as an IP address or a mount path, out of the Docker engine's record.
- **Launch containers with limits.** Start a detached container with an exact memory limit and a port mapping, and prove both took effect.
- **Use systemd timers.** Build a `.timer` and `.service` pair, write a schedule with `OnCalendar=`, catch up missed runs with `Persistent=`, and convert a cron job to a timer.

## The modules

Work through the modules in order. Each one ends with a graded mission that runs on its own training ship.

1. [Per-User Cron Job Scheduling](./module-01/course.md): where cron jobs live, the six-field and five-field line formats, and moving a job safely into a service account's crontab.
2. [Docker Container Lifecycle: Inspect, Stop, and Launch](./module-02/course.md): container states, `docker stop` and `docker kill`, `docker inspect --format`, and launching a container with a memory limit and a port mapping.
3. [systemd Timers](./module-03/course.md): the timer and service pair, schedule expressions, converting a cron job, and running timers day to day.

## Knowledge check and capstone

When you have finished the modules, test yourself with the [section quiz](./quiz.md).

Then take on the capstone, Scheduled Container Recovery. It joins the skills of the section: you retire an old container that holds a port, launch its replacement with limits, and schedule a per-user cron job that starts the new container again if it ever stops. Start it and open a terminal on it:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-020/capstone/labs/lab-01
astrona ssh ats-002-lab-020
```

Read the task in [`question.md`](./capstone/labs/lab-01/question.md). When you think you are done, send it for grading, and remove it afterwards:

```bash
astrona submit -c sections/section-020/capstone/labs/lab-01
astrona destroy ats-002-lab-020
```
