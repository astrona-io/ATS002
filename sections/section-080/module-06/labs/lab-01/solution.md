# Solution Walkthrough

This walkthrough finds the running kernel, confirms its initramfs image is missing, rebuilds it, and checks the result.

---

## Step 1: Name the running kernel and confirm the image is missing

```bash
uname -r
ls -l /boot/initrd.img-"$(uname -r)"
ls -l /boot
```

The first command prints the kernel release. The `ls` of the image fails with "No such file or directory". The listing of `/boot` shows the kernel file `vmlinuz-<release>` but no matching `initrd.img-<release>`.

---

## Step 2: Create the image

```bash
sudo update-initramfs -c -k "$(uname -r)"
```

- `-c` creates a new image. `-u` would update an existing one and has nothing to update here.
- `-k` names the kernel release. `$(uname -r)` fills in the running one.

This can take a short while. Add `-v` to see what it adds.

---

## Step 3: Check the image

```bash
ls -l /boot/initrd.img-"$(uname -r)"
sudo lsinitramfs /boot/initrd.img-"$(uname -r)" | head -20
```

The file exists and is not empty. `lsinitramfs` lists the files inside it. The image is readable by root only, so use `sudo`.

---

## Step 4: Check the link

```bash
ls -l /boot/initrd.img
```

`/boot/initrd.img` is a link to the image of the newest installed kernel. If it points at the image you just created, or at another image that exists, you are done. A link that points at a missing file would show in red in a colour terminal.

---

## Submit

```bash
astrona submit -c sections/section-080/module-06/labs/lab-01
```
