# Solution Walkthrough

Follow these steps to build an image, create a volume and a network, and start one container that uses all three. Add `sudo` in front of the `docker` commands if your user is not in the `docker` group. After each step you can send the lab for grading with `astrona submit -c sections/section-020/module-05/labs/lab-01`. Checks for the steps you have not done yet fail, and that is fine.

---

## Step 1: Write the Dockerfile

Save this as `/opt/course/25/build/Dockerfile`:

```dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
```

`FROM` picks the base image. `COPY` takes `index.html` from the build folder and puts it into the image. `COPY` can only read files inside the build folder, so the `Dockerfile` and the page must sit together.

## Step 2: Build and tag the image

```bash
docker build -t status-page:1.0 /opt/course/25/build
docker images status-page
```

`-t status-page:1.0` sets the exact name and tag the task asks for. The second command should list `status-page` with the tag `1.0`. Submit now: the first check should pass.

## Step 3: Create the volume and the network

```bash
docker volume create status-data
docker network create status-net
docker volume ls
docker network ls
```

Both names must appear in the listings.

## Step 4: Start the container

```bash
docker run -d \
  --name status-web \
  --network status-net \
  -v status-data:/data \
  status-page:1.0
```

`--network status-net` joins the network when the container starts. `-v status-data:/data` mounts the named volume at `/data`. Because the left side of `-v` is a name and not a path, Docker treats it as a named volume.

## Step 5: Read the result back

```bash
docker ps --filter name=status-web
docker inspect --format '{{ range .Mounts }}{{ .Type }} {{ .Name }} {{ .Destination }}{{ end }}' status-web
docker inspect --format '{{ range $name, $conf := .NetworkSettings.Networks }}{{ $name }} {{ end }}' status-web
```

The second command should print `volume status-data /data` and the third should print `status-net`. A typo in a name creates a new empty volume or fails the network step, so read the result back instead of trusting the command you typed.

When the checks look right, send the lab for grading:

```sh
astrona submit -c sections/section-020/module-05/labs/lab-01
```

---

## Command Summary

```bash
docker build -t status-page:1.0 /opt/course/25/build
docker volume create status-data
docker network create status-net
docker run -d --name status-web --network status-net -v status-data:/data status-page:1.0
docker inspect --format '{{ range .Mounts }}{{ .Type }} {{ .Name }} {{ .Destination }}{{ end }}' status-web
```
