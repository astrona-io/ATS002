# Catching a Process in the Act with strace (Playground)

- **ID:** PLAYGROUND
- **Slug:** strace-process-forensics
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground: a clean training ship, no task, no grading

A single training ship that starts, prepares the operating system, and keeps running so you can explore `strace` on a clean machine. Three demo `collector` processes run in the background so you have something to trace. There is nothing to submit.

## Run it

```sh
astrona run -c .
astrona destroy strace-process-forensics
```

`astrona destroy` takes the environment name (`metadata.name` = `strace-process-forensics`), not the folder path. `astrona submit` and `astrona test` do not apply, because there is no grading.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (runtime and bootstrap only) |
| `bootstrap/prepare.sh` | Operating system preparation, run once at start-up |
| `docs/overview.md` | What the environment contains and ideas to try |
