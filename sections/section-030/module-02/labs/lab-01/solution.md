# Reference solution

Run these commands inside the lab VM:

```bash
sudo virt-install --connect qemu:///system --virt-type qemu --arch x86_64 \
  --name inventory-db --memory 2048 --vcpus 2 \
  --disk path=/var/lib/libvirt/images/inventory-db.qcow2,format=qcow2,bus=virtio \
  --import --network network=default,model=virtio --osinfo generic \
  --graphics none --noautoconsole
sudo virsh autostart inventory-db
```

Wait for a lease, then check the service from the guest:

```bash
sudo virsh domifaddr inventory-db --source lease
ssh-keyscan -T 2 GUEST_ADDRESS
sudo virsh dumpxml --inactive inventory-db
sudo virsh dominfo inventory-db
```

Replace `GUEST_ADDRESS` with the lease address. The first boot can take three minutes with TCG. Check the console with `sudo virsh console inventory-db` if no lease appears; leave the console with Ctrl+]. The grader requires the assigned disk, persistent resources, autostart and a responding guest SSH service. CI also stops the guest to prove that a definition alone fails, restores it, then reboots the outer VM to test autostart.
