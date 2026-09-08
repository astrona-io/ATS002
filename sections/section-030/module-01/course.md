# Compile & Install From Source

Every package manager assumes someone already compiled the software correctly for your distribution. That assumption breaks when you are handed a source tarball — a vendor's internal tool, or a version the repos do not carry. Then you fall back to the oldest install method in Unix: unpack the source, run its build pipeline, and put the resulting binary exactly where the task says it must live — with the exact feature set the task specifies. This module covers each stage and, just as importantly, how to verify the result rather than trusting that the flags you passed did what you meant.

Three short parts; work them in order.

## How this module is organised

1. **[Part 1 — Unpacking the tarball, and the build pipeline](./course-01-unpacking-and-the-build-pipeline.md)** — matching `tar`'s compression flag to the extension, and the `./configure` → `make` → `sudo make install` pipeline where each stage produces the next stage's input (and why there is no `man configure`).
2. **[Part 2 — Discovering and choosing configure flags](./course-02-discovering-and-choosing-flags.md)** — `./configure --help` as the only flag reference, the two families it lists (installation-path flags vs feature toggles), and why `--bindir` beats `--prefix` when a task names an exact binary path.
3. **[Part 3 — Building, installing, and verifying](./course-03-building-installing-verifying.md)** — `make` / `sudo make install` and the `DESTDIR` / `prefix=` staging options, then verifying the path (`command -v`, `file`) and the feature toggle (the tool's own version output) independently, and closing the filename gap.

## Learning objectives

After this module you can:

- **Extract** a `.tar.bz2` / `.tar.gz` / `.tar.xz` tarball with the correct flags, and recognise a compression-mismatch failure.
- **Explain** what `./configure`, `make`, and `make install` each do, and why running them out of order fails.
- **Use** `./configure --help` to find the flags a task needs instead of guessing them.
- **Distinguish** installation-path flags from feature toggles, and choose `--bindir` over `--prefix` for an exact path.
- **Run** the build and install, using `DESTDIR` or a self-contained `--prefix` when appropriate.
- **Verify** the installed binary's path and its compiled-in features from the artefact itself, and rename it only when the build did not already use the required name.

## Before you start

Assumed: a Linux shell, `sudo`, `grep`, and a build toolchain present (`gcc`/`clang`, `make`, headers). No prior experience compiling software. Every command block states the directory and privilege it assumes. Builds can be slow — the examples use a small program (`links`) so the pipeline, not the wait, is the lesson.

## Where this fits

This module and the libvirt module are the section's two "assemble a raw building block yourself" skills — a tarball here, a disk image there — both demanding precise control over where the result lands and what it can do. The section capstone compiles a tool from source at an exact path with a feature disabled, then stands up a VM, in one maintenance window; the verification discipline from Part 3 is what makes the first half defensible.
