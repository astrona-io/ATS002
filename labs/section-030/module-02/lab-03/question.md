# Question

Solve this question on: `terminal`

The persistent domain `web-db` on this host is under-provisioned: it was
defined with only **512 MiB of memory and 1 vCPU**. It is currently
**shut off**.

Reconfigure it so the change is **permanent** — it must survive a host
reboot, not just last until the next full power-off:

1. Set `web-db` to **2048 MiB of memory** and **2 vCPUs** in its persistent
   configuration. Leave its disk and its `default` network attachment
   untouched.
2. Start the domain and confirm with `virsh dominfo web-db` that it is now
   running with `Max memory: 2097152 KiB` and `CPU(s): 2`.
3. Be ready to explain why `virsh setmem` / `virsh setvcpus` used *without*
   `--config` would not have satisfied this task.
