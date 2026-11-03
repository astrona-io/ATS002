# SELinux In Practice: Contexts, Booleans And Ports

Astronaut, SELinux is the security chief who reads tags instead of paths. When a service is refused, the cause is usually one of three things: a file with the wrong tag, a switch that is off, or a radio channel the chief does not know. This module teaches the commands that fix each of the three, and how to make the fix last.

Your training ship runs AppArmor, so it cannot run SELinux. Every command in this module is for a RHEL-family machine (Red Hat Enterprise Linux, Rocky Linux, AlmaLinux, Fedora). You read the commands, learn what each one does, and write them down. The mission checks the commands you write, not a live SELinux system.

## Learning objectives

After this module you can:

- Read a security context (`user:role:type:level`) with `ls -Z`, `ps -Z` and `id -Z`, and check the mode with `getenforce`.
- Explain why a moved file keeps its old label and a copied file gets the label of its new place.
- Fix a file label for now with `restorecon`, and for good with `semanage fcontext` followed by `restorecon`.
- Explain why `chcon` alone does not last.
- Read and set a boolean with `getsebool` and `setsebool -P`.
- Allow a new TCP port for a service with `semanage port`.
- Find denials with `ausearch -m avc -ts recent`, and tell permissive mode from disabled mode.

## Before you start

Check that you have the knowledge and the tools this module expects.

### What you should already know

- **How to work in a shell with `sudo`.** You can type commands and read their output.
- **What a file label is.** A security tag stuck on a crate. The rules compare tags, not paths.

### What is in your playground

Your playground is one Ubuntu 24.04 training ship. SELinux is not active on it, so the SELinux commands are written down and not run. It has a folder `/srv/web` with a sample page and an empty notes file `/root/selinux-notes.sh`. You use the notes file to write command sequences and check their shell syntax with `bash -n`.

Start the playground with `astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-040/module-02/playground`, then open a terminal on it with `astrona ssh astro-selinux-commands-bay`. When you are finished, remove it with `astrona destroy selinux-commands-bay`.

<!-- astrona:playground -->

## How this module is laid out

1. [Contexts And restorecon](./course-01-contexts-and-restorecon.md): reading a context, the `mv` versus `cp` rule, `restorecon`, and the lasting fix with `semanage fcontext`.
2. [Booleans, Ports And Reading Denials](./course-02-booleans-ports-and-reading-denials.md): `setsebool -P`, `semanage port`, `ausearch`, and the modes of SELinux.
   - Mission: [SELinux Fix Script Lab](./labs/lab-01/question.md)
3. [Wrap-Up: Mission Debrief](./course-03-wrap-up.md)

## Why this matters

An SELinux refusal does not look like a permission error that you can see with `ls -l`. The fix that works today and vanishes after a relabel or a reboot is the classic trap. The exam asks for the lasting version, so you need to know which command is temporary and which one is not.
