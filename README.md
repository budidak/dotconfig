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

rfkill unblock wifi
ip link set ´interface´ up

iwctl
# device list
# station list
# station <device_name> scan
# station <device_name> get-networks
# device <device_name> connect <network_ssid> --- then enter the passphrase for the network.
ip a
ping archlinux.org
timedatectl

vim /etc/pacman.conf
# Edit some lines for optimization before sync the repository.
pacman -Syy

pacstrap -K /mnt base base-devel linux linux-firmware linux-headers amd-ucode polkit iwd neovim --assume-installed sudo
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
  # LC_COLLATE=C
nvim /etc/vconsole.conf
  # KEYMAP=trq
nvim /etc/hostname
  # arch
nvim /etc/hosts
  # 127.0.0.1  localhost.localdomain  localhost
  # ::1        localhost.localdomain  localhost
  # 127.0.1.1  arch.localdomain       arch
nvim /etc/systemd/network/10-wireless.network
#  [Match]
#  Name=wlan0
#
#  [Network]
#  DHCP=yes
#  DNS=9.9.9.9
#  DNS=149.112.112.112

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

# AFTER REBOOT

```bash
run0 systemctl enable dbus
run0 systemctl enable iwd
run0 systemctl enable systemd.networkd
run0 systemctl enable systemd.resolved
run0 systemctl start dbus
run0 systemctl start iwd
run0 systemctl start systemd.networkd
run0 systemctl start systemd.resolved

run0 pacman -Syu foot fnott libnotify fuzzel tlp pipewire wireplumber brightnessctl slurp grim wl-clipboard tree \
htopyazi man-db man-pages bc texinfo less sqlite mariadb postgresql python python-pip nodejs npm yarn pnpm go git \
code hyprland hypridle hyprcursor hyprlock hyprpaper hyprpicker hyprpolkitagent hyprsunset hyprutils waybar \
noto-fonts noto-fonts-emoji nvidia-open nvtop vlc firefox wireguard-tools \
xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
mesa-utils vulkan-tools inxi dmidecode inetutils usbutils pciutils \
cronie ufw nginx openssh

systemctl enable pipewire --user
systemctl enable wireplumber --user
systemctl start pipewire --user
systemctl start wireplumber --user

# If pacman fails to sync repository (unable to unlock db) try:
# run0 find / -name "db.lck" 2>/dev/null   (possibly it will return '/var/lib/pacman/db.lck'
# run0 rm /var/lib/pacman/db.lck
# pacman -Syy

# TLP service activation:
run0 systemctl enable tlp
run0 systemctl start tlp

# UFW settings:
sudo systemctl enable ufw
sudo systemctl start ufw
sudo ufw enable
sudo ufw status verbose # it should be: incoming=deny, outgoing=allowed

# Wireguard settings: assume you name the file as "linux-vpn.conf"
wg-quick up /etc/wireguard/linux-vpn.conf
systemctl enable wg-quick@linux-vpn.service
systemctl start wg-quick@linux-vpn.service
ufw route allow out on wlan0
chown root:root /etc/wireguard/linux-vpn.conf
chmod 0640 /etc/wireguard/linux-vpn.conf
```

## NVIDIA

Check if nvidia is running or suspended. Read the docs: https://wiki.archlinux.org/title/PRIME

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
