# Summary

Well flown, astronaut. You have finished every part and the mission in this module. Before you move on, look back at what you learned, check yourself, and clean up anything still running.

## What you learned

This module was about packing your own crate, giving a pod a cargo hold that outlives it, and connecting pods over a network.

**From [Building An Image From A Dockerfile](./course-01-building-an-image-from-a-dockerfile.md):**

- A `Dockerfile` is the packing list: `FROM` picks the base, `COPY` and `RUN` add layers, `EXPOSE` is a note, `CMD` is the start command.
- `docker build -t name:tag folder` builds and tags an image. Without a tag you get `latest`.
- `docker history` lists the layers. The exec form of `CMD` passes `SIGTERM` on; the shell form does not.

**From [Volumes And Bind Mounts](./course-02-volumes-and-bind-mounts.md):**

- A named volume is managed by Docker and outlives every container that used it.
- `docker rm` leaves a volume alone. Only `docker volume rm` deletes it.
- A bind mount is a folder you look after. `--mount` is the explicit form of `-v`.

**From [Networks, Logs And Exec](./course-03-networks-logs-and-exec.md):**

- Containers on a user-defined network find each other by name. The default bridge gives no such lookup.
- `-p <host>:<container>` is still needed to reach a pod from outside.
- `docker logs --tail` and `-f` read the log, `docker exec -it <name> sh` steps inside, `docker rm`, `docker rmi` and `docker system prune` clean up.

## Your missions

You proved these skills in a graded mission, right after the part that taught the last of them:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [Container Images, Volumes And Networks Lab](./labs/lab-01/README.md) | Networks, Logs And Exec | built and tagged an image from a `Dockerfile`, ran a container with a named volume, and put it on a user-defined network |

If you skipped it, go back to it now. It is short, and the exam asks for exactly these skills.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. Which command builds the image <code>status-page:1.0</code> from the <code>Dockerfile</code> in <code>/opt/course/25/build</code>?</summary>

`docker build -t status-page:1.0 /opt/course/25/build`.
</details>

<details>
<summary>2. You remove a container with <code>docker rm -f db</code>. Where is the data it wrote into the named volume <code>dbdata</code>?</summary>

It is still in the volume `dbdata`. Only `docker volume rm dbdata` deletes it.
</details>

<details>
<summary>3. What is the difference between a named volume and a bind mount?</summary>

Docker creates and manages a named volume. A bind mount is a folder on the ship that you name with an absolute path.
</details>

<details>
<summary>4. Two containers must reach each other by name. What do you set up?</summary>

Create a network with `docker network create` and start both containers with `--network <name>`.
</details>

<details>
<summary>5. Why does a shell-form <code>CMD</code> make <code>docker stop</code> slow?</summary>

`/bin/sh` becomes the first process and does not pass `SIGTERM` on. Docker waits for the grace period and then sends `SIGKILL`.
</details>

## Clean up

Each mission runs a virtual machine on your computer, and so does your playground. When you are done with this module, remove them.

First, see what is still running:

```sh
astrona list
```

If the mission is still there, remove it. The command takes its **name**, not its folder path:

```sh
astrona destroy ats-002-lab-025
```

Remove the playground the same way:

```sh
astrona destroy container-build-bay
```

Then run `astrona list` again to check that everything is gone. You can start the playground again at any time with the `astrona run` command from the module's landing page. It always starts clean.

*An image is built with `docker build -t`, a named volume outlives its container, and a user-defined network gives name lookup.*

<!-- astrona:playground:destroy -->
