# Question

Solve this question on: `terminal`

The persistent domain `web-db` on this host is too small: it was defined with only **512 MiB of memory and 1 virtual CPU**. It is currently **shut off**. Work with the system libvirt instance (`qemu:///system`).

Change it so the new size is **permanent**: it must survive a host reboot, not just last until the next full power-off.

1. In the persistent configuration of `web-db`, set the memory to **2048 MiB**, both the maximum (`<memory>`) and the current allocation (`<currentMemory>`), and set **2 virtual CPUs**.
2. Leave its disk (`/var/lib/libvirt/images/web-db.qcow2`) and its `default` network attachment untouched. It must stay a persistent domain.
3. Start the domain and confirm with `virsh dominfo web-db` that it is now running with `Max memory: 2097152 KiB` and `CPU(s): 2`.

The grader checks the stored definition (`virsh dumpxml --inactive`) for `<memory>` of 2097152 KiB, `<currentMemory>` of at least 2097152 KiB and `<vcpu>` of 2, and the running domain for `State: running`, `Max memory: 2097152 KiB` and `CPU(s): 2`.

As practice, be ready to explain why `virsh setmem` or `virsh setvcpus` used *without* `--config` would not have solved this task.
