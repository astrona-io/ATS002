#!/usr/bin/env bash
set -euo pipefail
disk=$(readlink -f /dev/disk/by-id/virtio-lab080-vdc)
sudo sgdisk --load-backup=/root/vdc-ptable-backup.bin "$disk"
sudo partprobe "$disk"
sudo udevadm settle
#!/usr/bin/env bash
set -euo pipefail
sudo update-grub
if test -d /sys/firmware/efi; then
  case $(uname -m) in
    x86_64) target=x86_64-efi ;;
    aarch64) target=arm64-efi ;;
    *) echo 'Unsupported EFI architecture' >&2; exit 1 ;;
  esac
  sudo grub-install --target="$target" --efi-directory=/boot/efi --bootloader-id=ubuntu --recheck
else
  root_source=$(findmnt -no SOURCE /)
  disk=$(lsblk -no PKNAME "$root_source")
  test -n "$disk"
  sudo grub-install --recheck "/dev/$disk"
fi
sudo grub-script-check /boot/grub/grub.cfg
