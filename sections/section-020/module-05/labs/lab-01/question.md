# Question

Solve this question on: `terminal`

Astronaut, a new web pod must dock to this ship. Docker is running and the base image `nginx:alpine` is already pulled. The folder `/opt/course/25/build` holds one web page, `index.html`.

1. Write a `Dockerfile` in `/opt/course/25/build` that starts from `nginx:alpine` and copies `index.html` to `/usr/share/nginx/html/index.html`. Build the image with the name and tag `status-page:1.0`.
2. Create a Docker named volume called `status-data`.
3. Create a Docker network called `status-net`.
4. Start a detached container:
   - Name: `status-web`.
   - Image: `status-page:1.0`.
   - Mount the volume `status-data` at `/data` inside the container.
   - Attach it to the network `status-net`.

`status-web` must still be running when you submit.
<!-- curriculum-links -->

## Related lessons and assessment

Read [module-05](../../course.md).

The grader checks:

- Confirms the image status-page:1.0 exists and serves the page from index.html.
- Confirms status-web is running from status-page:1.0 with the named volume status-data at /data.
- Confirms status-web is on the user-defined network status-net.

Use the inspection commands in the solution to check your work. Submit when you have finished; submission ends this environment.
