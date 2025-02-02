# dotconfig
Configuration files for my Arch Linux setup.

## Installation

```bash
loadkeys trq
lsblk -f
wipefs -a /dev/nvme0n1
fdisk /dev/nvme0n1
# Use GPT partition. 1GB for the EFI boot partition, and the rest is for the Linux filesystem. (1 for EFI System, 20 for Linux Filesystem)

mkfs.vfat -F 32 -n ESP /dev/nvme0n1p1
mkfs.ext4 -L ROOT /dev/nvme0n1p2
# mkfs.btrfs -L ROOT /dev/nvme0n1p2
# BTRFS_OPTS = "rw,noatime,compress=zstd,ssd,discard=async"
# mount -o $BTRFS_OPTS /dev/nvme0n1p2 /mnt
# btrfs su cr /mnt/@
# btrfs su cr /mnt/@home
# btrfs su cr /mnt/@snapshots
# umount /mnt
# mount -o $BTRFS_OPTS,subvol=@ /dev/nvme0n1p2 /mnt
# mkdir -p /mnt/{boot,home,.snapshots}
# mount -o $BTRFS_OPTS,subvol=@home /dev/nvme0n1p2 /mnt/home
# mount -o $BTRFS_OPTS,subvol=@snapshots /dev/nvme0n1p2 /mnt/.snapshots
# READ: https://www.man7.org/linux/man-pages/man8/mount.8.html
# READ: https://www.man7.org/linux/man-pages/man5/ext4.5.html
EXT4_OPTS="rw,noatime,discard,async,delalloc,data=ordered,barrier=1,errors=remount-ro"
mount -o $EXT4_OPTS /dev/nvme0n1p2 /mnt
mkdir /mnt/boot
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

pacstrap -K base base-devel linux linux-firmware amd-ucode iwd neovim --assume-installed sudo
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
nvim /etc/locale.gen
  # uncomment --> en_US.UTF-8 UTF-8
locale-gen
nvim /etc/locale.conf
  # LANG=en_US.UTF-8
nvim /etc/vconsole.conf
  # KEYMAP=trq
nvim /etc/hostname
  # arch
nvim /etc/hosts
  # 127.0.0.1  localhost.localdomain  localhost
  # ::1        localhost.localdomain  localhost
  # 127.0.1.1  arch.localdomain       arch 

passwd  # set a password for the root.
useradd -m -G wheel -s /bin/bash by
passwd by  # set a password for the user.

ROOT_UUID=$(blkid -s UUID -o value /dev/nvme0n1p2)
echo $ROOT_UUID

mkinitcpio -P  # Create a new initramfs.

# Since I use just one OS on my machine, I prefer to not have any additional bootlader. With that reason I continue the installatation with EFI Boot stub.
efibootmgr --unicode  # List all efistub entries.
efibootmgr -b 0000 -B  # Delete the record labeled with 0000. (Delete all unneccessary entries)
# efibootmgr --create --disk /dev/nvme0n1 --part 1 --label "Arch Linux" --loader "\vmlinuz-linux" --unicode "root=UUID=$ROOT_UUID rw rootflags=subvol=@ loglevel=3 quiet initrd=\amd-ucode.img initrd=\initramfs-linux.img"
efibootmgr --create --disk /dev/nvme0n1 --part 1 --label "Arch Linux" --loader "\vmlinuz-linux" --unicode "root=UUID=$ROOT_UUID rw loglevel=3 quiet initrd=\amd-ucode.img initrd=\initramfs-linux.img"
exit
# EXITED THE CHROOTED ENVIRONMENT

umount -R /mnt
reboot
```

## Hardware Acceleration (for Chromium)

Install all the necessary packages. (For me, they are all placed inside the *packages.txt*)

Ensure that the NVIDIA drivers are correctly installed and loaded.
```bash
lsmod | grep nvidia
```

If you want to use Vulkan, ensure that you have the Vulkan drivers installed for your NVIDIA GPU. You can check if Vulkan is supported by running:
```bash
vulkaninfo
```

You can inspect other commands as well:
```bash
lspci | grep -E 'VGA|3D'  # Lists all connected GPUs.
vdpauinfo  # Shows details about capabilities of the GPU.
lscpu  # Shows details about the CPU.
nvidia-smi  # Check the status of your NVIDIA GPU. 
```

Blocklist nouveau modules, and allow nvidia modules. See */etc/modprobe.d/* folder.

Set the environment variables. See *~/.bash_profile* file.

```bash
sudo nvim /etc/mkinitcpio.conf  # edit the kernel modules.
sudo mkinicpio -P  # regenerates the kernel images.
```

In chromium, go to **chrome://flags** and set the following flags as enabled:
- Override software rendering list
- GPU rasterization
- Zero-copy rasterizer 
- Out-of-process 2D canvas rasterization.
- Skia Graphite
- Accelerated 2D canvas
- Hardware-accelerated video decode
- Parallel downloading

After enablling these flags, edit the hyprland config file. You need to run the chromium as shown below.

```bash
chromium --flag-switches-begin --enable-gpu-rasterization --enable-oop-rasterization --enable-zero-copy --ignore-gpu-blocklist --enable-gpu-early-init --enable-vulkan --enable-skia-graphite --enable-accelerated-2d-canvas --enable-accelerated-3d-canvas --enable-accelerated-video-decode --enable-gpu-compositing --enable-features=AcceleratedVideoDecodeLinuxGL,CanvasOopRasterization,ParallelDownloading --enable-logging=stderr --log-level=0
```

Go to page **chrome://gpu** and check if the acceleration enabled in Chromium.

Open a high resolution 4K video on YouTube and run the following commands to watch the effects on the GPUs.

```bash
radeontop  # View GPU Utilization for total activity percent and individual blocks. (for AMD cards)
nvtop  # Watch the current processes on both GPUs that the CPU has (iGPU) and the discrete GPU.
```
