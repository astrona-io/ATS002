# Question

Solve this question on: `terminal`

Astronaut, three nginx pods are on the docking schedule of this ship. Docker is installed and two containers, `frontend_v1` and `frontend_v2`, are running.

1. Stop the Docker container named `frontend_v1`. Stop it only; do not remove it.
2. Gather information from the Docker container named `frontend_v2`:
   - Write its assigned IP address into `/opt/course/11/ip-address`.
   - It has one volume mount. Write the mount's destination directory (the path inside the container) into `/opt/course/11/mount-destination`.
3. Start a new detached Docker container:
   - Name: `frontend_v3`.
   - Image: `nginx:alpine`.
   - Memory limit: `30m` (30 megabytes).
   - TCP port map: `1234/host` => `80/container`.

Each answer file must hold only the value, with no extra text. `frontend_v3` must still be running when you submit.
<!-- curriculum-links -->

## Related lessons and assessment

Read [module-02](../../course.md).

The grader checks:

- Confirms frontend_v1 shows STATUS Exited, not removed.
- Confirms /opt/course/11/ip-address matches frontend_v2's actual assigned IP address.
- Confirms /opt/course/11/mount-destination matches frontend_v2's actual volume mount destination.
- Confirms frontend_v3 is running, detached, image nginx:alpine, memory limit 30m, and port map 1234->80.

Use the inspection commands in the solution to check your work. Submit when you have finished; submission ends this environment.
