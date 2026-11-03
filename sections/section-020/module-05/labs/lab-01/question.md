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
