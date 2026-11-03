# Summary

Well flown, astronaut. You have finished every part and the mission in this module. Before you move on, look back at what you learned, check yourself, and clean up anything still running.

## What you learned

This module was about docking pods without a standing docking crew, and about docking them as a normal crew member.

**From [Podman As A Docker-Compatible Engine](./course-01-podman-as-a-docker-compatible-engine.md):**

- Podman has no daemon. Each command does its work and starts a small monitor, `conmon`, for the container.
- `podman run`, `ps`, `images`, `pull`, `stop` and `rm` work like the Docker commands.
- Write fully qualified image names such as `docker.io/library/nginx:alpine`. Short names depend on `unqualified-search-registries` in `/etc/containers/registries.conf`.
- Each user has a separate store of images and containers.

**From [Rootless Containers And systemd](./course-02-rootless-containers-and-systemd.md):**

- A rootless container uses a user namespace built from the ranges in `/etc/subuid` and `/etc/subgid`.
- Its data lives under `~/.local/share/containers`.
- A normal user cannot publish ports below `net.ipv4.ip_unprivileged_port_start` (1024 by default).
- `loginctl enable-linger <user>` keeps the user's services running after logout.
- A Quadlet `.container` file in `~/.config/containers/systemd/` becomes a user service after `systemctl --user daemon-reload`.

## Your missions

You proved these skills in a graded mission, right after the part that taught the last of them:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [Rootless Podman Container Lab](./labs/lab-01/README.md) | Rootless Containers And systemd | ran a rootless container as a normal user with a published high port, saved its image ID, and kept the user's services running after logout |

If you skipped it, go back to it now. It is short, and the exam asks for exactly these skills.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. Why is there no <code>systemctl status podman</code> to check, like there is for Docker?</summary>

Podman has no daemon. Each command does its work and leaves a small monitor next to the container.
</details>

<details>
<summary>2. Why do you write <code>docker.io/library/nginx:alpine</code> and not <code>nginx:alpine</code>?</summary>

The fully qualified name works on every machine. A short name depends on the registries list in `/etc/containers/registries.conf`.
</details>

<details>
<summary>3. A user has no line in <code>/etc/subuid</code>. What do you do?</summary>

Run `sudo usermod --add-subuids <first>-<last> <user>`, and the same with `--add-subgids`.
</details>

<details>
<summary>4. A rootless container is stopped when its user logs out. What fixes it?</summary>

`sudo loginctl enable-linger <user>`.
</details>

<details>
<summary>5. Why does <code>podman run -p 80:80 ...</code> fail for a normal user?</summary>

Port 80 is below `net.ipv4.ip_unprivileged_port_start`, which is 1024 by default. Use a higher port.
</details>

## Clean up

Each mission runs a virtual machine on your computer, and so does your playground. When you are done with this module, remove them.

First, see what is still running:

```sh
astrona list
```

If the mission is still there, remove it. The command takes its **name**, not its folder path:

```sh
astrona destroy ats-002-lab-026
```

Remove the playground the same way:

```sh
astrona destroy podman-rootless-bay
```

Then run `astrona list` again to check that everything is gone. You can start the playground again at any time with the `astrona run` command from the module's landing page. It always starts clean.

*Podman needs no daemon, a rootless container needs an ID range and a high port, and lingering keeps it alive after logout.*

<!-- astrona:playground:destroy -->
