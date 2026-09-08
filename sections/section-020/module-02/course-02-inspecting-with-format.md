# Part 2 — Inspecting with `--format`, and launching with constraints

> Prerequisite: [Part 1 — The container lifecycle, and stopping one cleanly](./course-01-the-container-lifecycle-and-stopping.md). Next: [Section 020 quiz](../quiz.md).

`docker inspect` prints the daemon's entire record of a container as JSON — creation config and live runtime state together. `--format` runs a template over that same structure and returns one answer. This part is the template language, the fields that matter, launching a container with resource limits, and verifying the limits actually took.

## What `docker inspect` is showing you

```bash
docker inspect frontend_v2        # the full JSON — a hundred-plus lines
```

The document has two halves worth knowing apart:

- **`.Config`** — what you asked for at *create* time: `Image`, `Env`, `Cmd`, `ExposedPorts`, `Labels`. Immutable for the life of the container.
- **`.State`, `.NetworkSettings`, `.Mounts`, `.HostConfig`** — *runtime* facts the daemon maintains: current status, PID, IP addresses, resolved mounts, applied resource limits.

Reading it by eye is like being handed a ship's whole cargo manifest to find one crate. `--format` is asking the one question.

## The `--format` template language

`--format` is Go's `text/template` run against the inspect JSON. The pieces you need:

| Syntax | Does |
|---|---|
| `{{ .Field.Sub }}` | walk the struct — `.NetworkSettings.IPAddress` |
| `{{ range .Map }} … {{ end }}` | iterate an array or map without naming keys |
| `{{ index .Arr 0 }}` | the Nth element of an array |
| `{{ len .Arr }}` | length |
| `{{ json .Field }}` | dump that subtree as JSON |
| `{{ printf "%s" .X }}` | format |

```bash
docker inspect --format '{{ .NetworkSettings.IPAddress }}' frontend_v2
```

`.NetworkSettings.IPAddress` is populated **only for containers on the default bridge network**. Off the default bridge, Docker tracks addresses per-network and this top-level field is empty. The network-name-agnostic form:

```bash
docker inspect --format '{{ range .NetworkSettings.Networks }}{{ .IPAddress }}{{ end }}' frontend_v2
```

`range` over the `Networks` map visits each attached network's entry; `.IPAddress` inside the loop is that network's address. Works whether the container is on `bridge`, `my-app-net`, or several at once.

### Addressing arrays without hardcoding an index you eyeballed

Volume mounts are `.Mounts`, a JSON array. Even when a task says "the container has one mount", do not hardcode `0` after counting by eye — address it generically:

```bash
docker inspect --format '{{ (index .Mounts 0).Destination }}' frontend_v2
docker inspect --format '{{ len .Mounts }}' frontend_v2          # check the count first
```

`index .Mounts 0` returns the first mount object; `.Destination` on it is the in-container path.

## Launching with an exact ceiling

```bash
docker run -d \
  --name frontend_v3 \
  --memory=30m \
  -p 1234:80 \
  nginx:alpine
```

- **`-d`** — detach; the container runs in the background, you get the prompt back.
- **`--name frontend_v3`** — a fixed name instead of a random `adjective_scientist`.
- **`--memory=30m`** — caps the container's cgroup memory at 30 MiB. Exceed it and the kernel OOM-killer terminates the process inside rather than letting it grow. Stored internally in **bytes**.
- **`-p 1234:80`** — maps **host** port 1234 → **container** port 80. Left is always host-facing, right is what the process inside listens on. Reversed, you publish a host port nothing is bound to.

## Verify the running state, not the command you typed

A typo in `-p` or `--memory` fails silently from the shell's side. Check what the daemon actually built:

```bash
docker ps --filter 'name=frontend_v3'
docker inspect --format '{{ .HostConfig.Memory }}' frontend_v3
docker stats --no-stream frontend_v3
```

- `docker ps --filter` — the `PORTS` column shows `0.0.0.0:1234->80/tcp` if the mapping took.
- `{{ .HostConfig.Memory }}` — the limit in bytes: 30 MiB is `31457280` (`30 × 1024 × 1024`). `0` means no limit was applied.
- `docker stats --no-stream` — one-shot snapshot of live usage against the limit, no continuously-updating pane.

> [!WARNING]
> - **Reversed `-p` mapping.** `-p 80:1234` publishes host 80 → container 1234; nothing listens there. Host port is always on the left.
> - **`.NetworkSettings.IPAddress` empty and assuming no network.** It is only set on the default bridge; use `range .NetworkSettings.Networks`.
> - **Reading `.HostConfig.Memory` as MiB.** It is bytes — `31457280`, not `30`. Convert before calling it a mismatch.
> - **Hardcoding `index .Mounts 0` without `len .Mounts`.** Confirm the array shape first; a template that assumes an element that is not there errors.

> *`docker inspect` is the daemon's full JSON record (create-time `.Config` plus runtime `.State`/`.NetworkSettings`/`.HostConfig`); `--format` runs a Go template over it — use `range` for per-network addresses, `index`/`len` for arrays, and verify `--memory` (bytes) and `-p` (host:container) from that record, not from the command line.*

## Reference

- `docker inspect --help` and Go `text/template` docs — `range`, `index`, `len`, `json`, `printf`.
- `docker run --help` — `--memory`, `--cpus`, `-p`, `-d`, `--name`, `--init`.
- `docker stats --help` / `docker ps --help` — `--no-stream`, `--filter`, `--format` (same template engine).
