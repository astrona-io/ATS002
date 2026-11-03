# Solution: Rootless Podman Container Lab

Try the task yourself first. Check each step with `astrona submit -c sections/section-020/module-06/labs/lab-01` as you go.

## Step 1: Start the container as pilot

Open a login for `pilot`:

```sh
sudo machinectl shell pilot@
```

Start the container:

```sh
podman run -d --name relay -p 8090:80 docker.io/library/nginx:alpine
podman ps
```

## Step 2: Save the image ID

Still as `pilot`:

```sh
podman inspect --format '{{ .Image }}' relay > ~/relay-image-id.txt
cat ~/relay-image-id.txt
```

Leave the `pilot` shell with `exit`.

## Step 3: Keep the services after logout

As your own user, with `sudo`:

```sh
sudo loginctl enable-linger pilot
loginctl show-user pilot --property=Linger
```

The last command prints `Linger=yes`.

## Why this works

- Rootless Podman uses the ID ranges of `pilot` in `/etc/subuid` and `/etc/subgid`, and stores its data in the home folder.
- Port 8090 is above 1024, so a normal user may publish it.
- Lingering keeps the user service manager running with no login.
