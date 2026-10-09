# Inspecting With --format

Astronaut, the Docker engine keeps a full record of every pod it has docked. `docker inspect` prints that whole record as JSON (a text format of nested names and values). `--format` runs a small template over the same record and gives back one answer. This part covers what the record holds, the template language, and how to pull out an IP address and a mount path.

The examples use a running container named `web_demo`. Use any container you have, and add `sudo` if your user is not in the `docker` group.

## What `docker inspect` shows you

Start with the whole record, so you know what you are searching:

```bash
docker inspect web_demo        # the full JSON, a hundred lines or more
```

### Two halves of the record

The record has two halves that are worth telling apart:

- **`.Config`** is what you asked for when the container was created: `Image`, `Env`, `Cmd`, `ExposedPorts`, `Labels`. It does not change while the container exists.
- **`.State`, `.NetworkSettings`, `.Mounts` and `.HostConfig`** hold the facts the Docker engine keeps up to date while the container runs: its current status, its PID, its IP addresses, its mounts and the resource limits it applied.

Reading the whole record by eye is like reading a ship's full cargo manifest to find one crate. `--format` lets you ask for exactly that crate.

## The `--format` template language

`--format` uses Go's `text/template` language and runs it against the inspect JSON. Go is the programming language Docker is written in. You only need a handful of pieces.

### The pieces you need

| Syntax | Does |
|---|---|
| `{{ .Field.Sub }}` | walks into the record, for example `.NetworkSettings.IPAddress` |
| `{{ range .Map }} … {{ end }}` | goes through every item of a list or map without naming the keys |
| `{{ index .Arr 0 }}` | picks item number N of a list (counting from 0) |
| `{{ len .Arr }}` | counts the items |
| `{{ json .Field }}` | prints that part of the record as JSON |
| `{{ printf "%s" .X }}` | formats a value |

### Read an IP address

Ask for the container's IP address directly:

```bash
docker inspect --format '{{ .NetworkSettings.IPAddress }}' web_demo
```

Docker fills `.NetworkSettings.IPAddress` **only for containers on the default bridge network**. On any other network, Docker keeps one address per network, and this top-level field is empty. This form works whatever the network is called:

```bash
docker inspect --format '{{ range .NetworkSettings.Networks }}{{ .IPAddress }}{{ end }}' web_demo
```

`range` visits the entry for each network the container is attached to, and `.IPAddress` inside the loop is that network's address. It works whether the container is on `bridge`, on `my-app-net`, or on several networks at once.

## Reading a list without guessing

Some parts of the record are lists. Volume mounts are `.Mounts`, a JSON list with one entry per mount. A mount is a hatch between the pod and one of the ship's cargo holds: a folder on the host that the container sees at a path of its own.

### Count first, then pick

Even when a task says "the container has one mount", do not pick an item you counted by eye. Count the list first, then pick the item by its position:

```bash
docker inspect --format '{{ len .Mounts }}' web_demo             # check the count first
docker inspect --format '{{ (index .Mounts 0).Destination }}' web_demo
```

`index .Mounts 0` returns the first mount entry. `.Destination` on that entry is the path inside the container. `.Source` would be the folder on the host.

> [!TIP]
> To save a value for later, send the `--format` output straight to a file with `>`. Redirection does not create missing folders, so create the folder with `mkdir -p` first.

## Common pitfalls

> [!WARNING]
> - **An empty `.NetworkSettings.IPAddress`, read as "no network".** It is only set on the default bridge. Use `range .NetworkSettings.Networks`.
> - **Using `index .Mounts 0` without `len .Mounts`.** Check the shape of the list first. A template that asks for an item that is not there fails with an error.
> - **Mixing up `.Destination` and `.Source`.** The destination is the path inside the container; the source is the folder on the host.
