# Overview: Third-Party Repositories and Pinning Playground

This is a **playground**, not a lab. The training ship starts clean, runs its setup script, and then waits for you. There is no task, no `astrona submit` and no pass or fail. Explore, break things, remove it with `astrona destroy` and start over.

## What is in the box

- One Ubuntu 24.04 virtual machine. Open a terminal on it with `astrona ssh astro-apt-repos-and-pinning`.
- A fake vendor repository, built on the machine and served over plain HTTP on `127.0.0.1:8100` by the `vendor-repo-server.service` unit. The files live in `/srv/vendor-repo`. Its suite is called `vendor-nginx`, and it holds one package, `nginx`, at version `1.25.4-1~vendorfake1`.
- The vendor's public signing key, published at `http://127.0.0.1:8100/vendor-nginx-archive-keyring.asc`. `apt` does not trust this repository yet: adding the key, the source file, the pin and the hold is your job.
- `curl` installed, and both the `noble` and `noble-updates` pockets enabled, so `apt-cache policy curl` shows two competing versions. No pin exists yet.
- `reprepro` and `gnupg`, the tools that built the repository.

## Things to try

- Run `apt-cache policy nginx` and note which source `apt` prefers today.
- Download the vendor key with `curl`, turn it into a keyring with `gpg --dearmor`, and store it under `/etc/apt/keyrings/`.
- Write a `.sources` or `.list` file under `/etc/apt/sources.list.d/` that uses `signed-by=`, run `sudo apt update`, and read `apt-cache policy nginx` again.
- Install the exact vendor version with `sudo apt install nginx=1.25.4-1~vendorfake1`, then hold it with `sudo apt-mark hold nginx` and check `apt-mark showhold`.
- Write a pin in `/etc/apt/preferences.d/` that fixes `curl` to the `noble` pocket, then check `apt-cache policy curl`.

## When you are done

```sh
astrona destroy apt-repos-and-pinning
```

`astrona destroy` takes the playground's name, `apt-repos-and-pinning`, not the folder path. The running machine is called `astro-apt-repos-and-pinning`.
