# Overview: Compile & Install From Source Playground

This is a **playground**, not a lab. The training ship starts clean, runs its preparation script once, and then waits for you. There is no task, no `astrona submit` and no pass or fail. Explore, break things, run `astrona destroy`, and start over.

## What's in the box

Your playground is a workbench with one kit of parts on it:

- A single Ubuntu 24.04 `qemu` virtual machine. Reach it with `astrona ssh astro-source-build-bay`.
- A C compiler (`gcc`) and `make`, installed with the `build-essential` package if the image did not have them.
- The source tarball `/tools/links-2.14.tar.bz2`. It holds a small autoconf-style project with a real `configure` script and C source. It is bzip2-compressed, so `tar xjf` is the right way to open it.
- Nothing is built or installed yet, and `links` is not on the machine.

## Things to try

- Copy the tarball somewhere you own, such as `/tmp`, and unpack it with `tar xjf links-2.14.tar.bz2`. Try `tar xzf` on it once to see the error for the wrong flag.
- Run `./configure --help` inside the folder and filter it: `./configure --help | grep -i bindir` and `./configure --help | grep -i ipv6`.
- Run `./configure --bindir=/usr/bin --disable-ipv6`, then `make` and `sudo make install`.
- Check the result on the program: `command -v links`, `file /usr/bin/links` and `links -version`.
- Install into a scratch folder with `make install DESTDIR=/tmp/stage` and look at what lands under it.

## When you're done

```sh
astrona destroy source-build-bay
```

`astrona destroy` takes the playground's name, not the folder path. The terminal command uses `astro-source-build-bay`; the `astro-` prefix is optional there. The name for `astrona destroy` is `source-build-bay`.
