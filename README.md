# dotconfig
Configuration files for my Arch Linux setup.

## Installation

```bash
loadkeys trq

lsblk -f

wipefs -a /dev/nvme0n1

fdisk /dev/nvme0n1
# Use GPT partition. 1GB for the EFI boot partition, and the rest is for the Linux filesystem.

mkfs.vfat -F 32 -n ESP /dev/nvme0n1p1
mkfs.btrfs -L ROOT /dev/nvme0n1p2

BTRFS_OPTS = "rw,noatime,compress=zstd,ssd,discard=async"
mount -o $BTRFS_OPTS /dev/nvme0n1p2 /mnt
btrfs su cr /mnt/@
btrfs su cr /mnt/@home
btrfs su cr /mnt/@snapshots
umount /mnt
mount -o $BTRFS_OPTS,subvol=@ /dev/nvme0n1p2 /mnt
mkdir -p /mnt/{boot,home,.snapshots}
mount -o $BTRFS_OPTS,subvol=@home /dev/nvme0n1p2 /mnt/home
mount -o $BTRFS_OPTS,subvol=@snapshots /dev/nvme0n1p2 /mnt/.snapshots
mount /dev/nvme0n1p1 /mnt/boot

iwctl
# device list
# station <device_name> scan
# station <device_name> get-networks
# device <device_name> connect <network_ssid> --- then enter the passphrase for the network.
ip a
ping archlinux.org
timedatectl

vim /etc/pacman.conf
# Edit some lines for optimization before sync the repository.

pacman -Syy

pacstrap -K base base-devel linux linux-firmware amd-ucode iwd dhcpcd neovim --assume-installed sudo
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt

# CHROOTED ENVIRONMENT
nvim /etc/pacman.conf # Edit some lines for optimization and activate multilib.
pacman -Syy
pacman -Syu curl wget efibootmgr
curl -O https://raw.githubusercontent.com/budidak/dotconfig/refs/heads/main/packages.txt  # Download the text file.
pacman -S --needed - < packages.txt  # Install the packages from the text file.

ln -sf /usr/share/zoneinfo/Europe/Istanbul /etc/localtime
hwclock --systohc
nvim /etc/locale.gen  # uncomment en_US.UTF-8 UTF-8
locale-gen
nvim /etc/locale.conf  # LANG=en_US.UTF-8
nvim /etc/vconsole.conf  # KEYMAP=trq
nvim /etc/hostname  # arch

passwd  # set a password for the root.
useradd -m -G wheel -s /bin/bash by
passwd by  # set a password for the user.

ROOT_UUID=$(blkid -s UUID -o value /dev/nvme0n1p2)
echo $ROOT_UUID

mkinitcpio -P  # Create a new initramfs.

# Since I use just one OS on my machine, I prefer to not have any additional bootlader. With that reason I continue the installatation with EFI Boot stub.
efibootmgr --unicode  # List all efistub entries.
efibootmgr -b 0000 -B  # Delete the record labeled with 0000. (Delete all unneccessary entries)
efibootmgr --create --disk /dev/nvme0n1 --part 1 --label "Arch Linux" --loader "\vmlinuz-linux" --unicode "root=UUID=$ROOT_UUID rw rootflags=subvol=@ loglevel=3 quiet initrd=\amd-ucode.img initrd=\initramfs-linux.img"

exit
# EXITED THE CHROOTED ENVIRONMENT

umount -R /mnt
reboot
```
