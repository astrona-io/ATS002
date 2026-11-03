# Docker Container Lifecycle Playground

- **Slug:** docker-lifecycle-bay
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground: a clean training ship, no task, no grading

This playground is a single Ubuntu 24.04 virtual machine that acts as your docking bay. When it starts, it makes sure the Docker engine runs, pulls the `nginx:alpine` image, and docks one container. Then it waits for you. There is nothing to submit.

## Run it

From the course repository:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-020/module-02/playground
astrona ssh astro-docker-lifecycle-bay
```

From inside this folder, `astrona run -c .` starts the same playground.

When you are done, remove it:

```sh
astrona destroy docker-lifecycle-bay
```

`astrona destroy` takes the playground's name (`docker-lifecycle-bay`, the `metadata.name` in `config.yaml`), not the folder path. `astrona submit` and `astrona test` do not apply, because nothing is graded.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Playground definition (the virtual machine and its start-up step only) |
| `bootstrap/prepare.sh` | Preparation that runs once when the playground starts |
| `docs/overview.md` | What the playground contains and ideas to try |
