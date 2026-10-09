# Kernel Modules: Loading, Parameters, and Blacklisting (Playground)

- **ID:** PLAYGROUND
- **Slug:** kernel-modules-lab
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground: a clean training ship, no task, no grading

A single training ship that starts, prepares the operating system, and keeps running so you can explore kernel modules on a clean machine. There is nothing to submit.

## Run it

```sh
astrona run -c .
astrona destroy kernel-modules-lab
```

`astrona destroy` takes the environment name (`metadata.name` = `kernel-modules-lab`), not the folder path. `astrona submit` and `astrona test` do not apply, because there is no grading.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (runtime and bootstrap only) |
| `bootstrap/prepare.sh` | Operating system preparation, run once at start-up |
| `docs/overview.md` | What the environment contains and ideas to try |
