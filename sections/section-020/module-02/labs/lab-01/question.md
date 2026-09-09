# Question

Solve this question on: `terminal`

Stop the Docker container named `frontend_v1`.

Gather information from the Docker container named `frontend_v2`:
- Write its assigned IP address into `/opt/course/11/ip-address`.
- It has one volume mount. Write the volume mount's destination directory into `/opt/course/11/mount-destination`.

Start a new detached Docker container:
- Name: `frontend_v3`.
- Image: `nginx:alpine`.
- Memory limit: `30m` (30 megabytes).
- TCP port map: `1234/host` => `80/container`.
