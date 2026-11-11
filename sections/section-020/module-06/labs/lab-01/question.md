# Rootless Podman Container Lab

A normal crew member, `pilot`, must dock a web pod without any captain's authority, and the pod must survive when `pilot` logs out.

## Your task

Work as the user `pilot` for the container steps. The `pilot` account already exists with its ID ranges.

1. As `pilot`, start a detached container named `relay` from the image `docker.io/library/nginx:alpine`. Publish host port `8090` to container port `80`.
2. Save the image ID of the container `relay` in `/home/pilot/relay-image-id.txt`.
3. Make sure the services of `pilot` keep running after `pilot` logs out.

## Hints

- Use the fully qualified image name.
- Port 8090 is above the lowest port a normal user may open.
- `podman inspect --format '{{ .Image }}' relay` prints the image ID.
- Lingering is switched on by an administrator, not by `pilot`.

## What is graded

- `pilot` runs the container `relay` from `nginx:alpine`, published on host port 8090.
- Lingering is enabled for `pilot`.
- `/home/pilot/relay-image-id.txt` holds the image ID of `relay`.
<!-- curriculum-links -->

## Related lessons and assessment

Read [module-06](../../course.md).

The grader checks:

- Confirms pilot runs the container relay from docker.io/library/nginx:alpine, published on host port 8090.
- Confirms lingering is enabled for pilot.
- Confirms /home/pilot/relay-image-id.txt holds the image ID of the container relay.

Use the inspection commands in the solution to check your work. Submit when you have finished; submission ends this environment.
