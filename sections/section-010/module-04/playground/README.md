# udev: Giving a Device a Name It Can Keep (Playground)

- **ID:** PLAYGROUND
- **Slug:** udev-stable-naming
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground: a clean training ship, no task, no grading

A single training ship that starts, prepares the operating system, and keeps running so you can explore udev on a clean machine. It has a spare disk with a fixed serial number to write rules for. There is nothing to submit.

## Run it

```sh
astrona run -c .
astrona destroy udev-stable-naming
```

`astrona destroy` takes the environment name (`metadata.name` = `udev-stable-naming`), not the folder path. `astrona submit` and `astrona test` do not apply, because there is no grading.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (runtime and bootstrap only) |
| `bootstrap/prepare.sh` | Operating system preparation, run once at start-up |
| `docs/overview.md` | What the environment contains and ideas to try |
