# Building An Image From A Dockerfile

Astronaut, an image is a sealed crate with a ready-to-run module inside. A **`Dockerfile`** is the packing list for that crate: a plain text file with one instruction per line. In this part you pack a small web page into an nginx crate, build it, and read the crate's layers back.

## One real build

Start with a case you can run. The playground holds a web page at `/opt/demo/status-page/index.html`. You pack it into the `nginx:alpine` image, so a pod made from your crate serves that page.

<!-- astrona:playground:renew -->

### See it in your playground

Save this as `/opt/demo/status-page/Dockerfile`:

```dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
```

Apply it. The Docker engine reads the `Dockerfile` in the folder you name, runs each instruction and tags the result `status-page:1.0`:

```sh
docker build -t status-page:1.0 /opt/demo/status-page
```

Then check the result:

```sh
docker images status-page
```

The list shows one line for the repository `status-page` with the tag `1.0`, an image ID and a size. Your crate exists. Nothing is running yet, because an image is only a crate and not a pod.

## What each instruction does

The Docker engine builds the image from the top to the bottom of the file. This table lists the instructions you need.

| Instruction | What it does |
| --- | --- |
| `FROM nginx:alpine` | Starts from an existing crate. Every `Dockerfile` begins with `FROM`. |
| `COPY index.html /usr/share/nginx/html/index.html` | Copies a file from the build folder into the image. |
| `RUN <command>` | Runs a command while the image is built, for example to install a package. |
| `EXPOSE 80` | Notes that the process inside listens on port 80. It does not open anything on the ship. |
| `CMD [...]` | Sets the command that runs when a container starts from the image. |

The build folder you name at the end of `docker build` is called the **build context**. `COPY` can only take files from inside it.

## Tags name your crate

`-t status-page:1.0` gives the image a name and a version tag. If you leave the tag out, Docker uses `latest`. A task that says "build the image `status-page:1.0`" is graded on that exact name, so a missing or different tag fails.

### Run a pod from it

Start a container from the new image, and ask it for the page. The `-p 8080:80` option patches ship port 8080 through to pod port 80.

```sh
docker run -d --name page -p 8080:80 status-page:1.0
curl -s http://127.0.0.1:8080
```

The reply is the content of your `index.html`. The pod serves the file you packed, not one from the ship's disk.

## Layers

Each instruction that changes files adds a **layer** to the image, like a sealed shelf stacked on the one below. `docker history` lists the layers from the newest to the oldest.

```sh
docker history status-page:1.0
```

You see one row for your `COPY` line on top of the layers of `nginx:alpine`. A layer that did not change is reused in the next build, which makes later builds fast.

## Exec form against shell form

`CMD` has two forms. The **exec form** is a list: `CMD ["nginx", "-g", "daemon off;"]`. The **shell form** is plain text: `CMD nginx -g "daemon off;"`. The shell form starts the command inside `/bin/sh -c`, so `sh` becomes the first process of the container, and it does not pass the stop signal on. Use the exec form for the command that must receive `SIGTERM` from `docker stop`.

## Common pitfalls

> [!WARNING]
> - **A missing or different tag.** `docker build -t status-page .` builds `status-page:latest`, not `status-page:1.0`. Write the tag you were asked for.
> - **A file outside the build context.** `COPY ../notes.txt .` fails. Only files inside the folder you name can be copied.
> - **Reading `EXPOSE` as a port mapping.** `EXPOSE` is a note. Only `-p` on `docker run` opens a ship port.
> - **A build that needs `sudo` for `docker`.** If you get a permission error on the Docker socket, add `sudo` to the command.

*An image is a crate packed from a `Dockerfile`: `FROM` picks the base, `COPY` and `RUN` add layers, `docker build -t name:tag folder` builds it, and the exec form of `CMD` passes signals on.*
