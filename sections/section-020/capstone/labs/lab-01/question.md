# Question

Solve this question on: `terminal`

Astronaut, a retired pod named `billing_v1` is still docked and running. It holds host port `9090`, the exact port its replacement needs.

1. Retire `billing_v1` completely: stop it **and** remove the container, so port `9090` is free and the container no longer exists.
2. Launch its replacement as a new detached container:
   - Name: `billing_v2`.
   - Image: `nginx:alpine`.
   - Memory limit: `64m` (64 megabytes).
   - TCP port map: `9090/host` => `80/container`.
3. The service account `ops-monitor` already exists and is a member of the `docker` group. Write a small script that checks whether `billing_v2` is running and starts it again if it is not. Schedule that script in `ops-monitor`'s own per-user crontab to run **every minute** (`* * * * *`), so `billing_v2` recovers on its own if it ever crashes or is stopped.

The grader stops `billing_v2` on purpose and expects it to be running again within about 90 seconds.
<!-- curriculum-links -->

## Related lessons and assessment

Read [module-01](../../../module-01/course.md), [module-02](../../../module-02/course.md), [module-03](../../../module-03/course.md), [module-04](../../../module-04/course.md), [module-05](../../../module-05/course.md), [module-06](../../../module-06/course.md).

The grader checks:

- Confirms the decommissioned billing_v1 container no longer exists.
- Confirms billing_v2 is running, image nginx:alpine, memory limit 64m, and port map 9090->80.
- Confirms ops-monitor is in the docker group, so its cron job can actually run docker commands.
- Confirms ops-monitor's per-user crontab has a job scheduled every minute that restarts billing_v2.
- Stops billing_v2 to simulate a crash and confirms the scheduled cron job automatically restarts it within about 90 seconds.

Use the inspection commands in the solution to check your work. Submit when you have finished; submission ends this environment.
