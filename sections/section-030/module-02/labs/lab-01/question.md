# Boot and manage a libvirt guest

**Learner work: 15 minutes.** First guest boot can take another three minutes under software emulation.

The host has libvirt and its default NAT network. A checksum-verified CirrOS 0.6.3 image is staged at `/var/lib/libvirt/images/inventory-db.qcow2`. It contains a small Linux system. The domain is not defined yet.

1. Import the disk as a persistent domain named `inventory-db`, with 2048 MiB of memory and two virtual CPUs. Select `--virt-type qemu --arch x86_64` explicitly: software emulation works even when this outer VM has no nested KVM.
2. Attach the default libvirt network and start the domain. Use `virsh domifaddr inventory-db --source lease` to find its DHCP address. Confirm the guest's SSH service responds with `ssh-keyscan -T 2 ADDRESS`.
3. Enable domain autostart. Inspect the persistent configuration with `virsh dumpxml --inactive inventory-db` and keep the guest running for submission.

A `running` domain only proves that the QEMU process exists. The guest address and SSH service prove that Linux booted. Do not replace the staged disk or create a host service to stand in for the guest. This isolated training image uses public CirrOS credentials and must not be exposed outside the lab network.

Run `astrona submit` once, after your checks. Submission destroys this lab.
<!-- curriculum-links -->

## Related lessons and assessment

Read [module-02](../../course.md).

The grader checks:

- Checks persistent domain resources, autostart, the assigned disk, a guest DHCP lease and a live SSH service.

Use the inspection commands in the solution to check your work. Submit when you have finished; submission ends this environment.
