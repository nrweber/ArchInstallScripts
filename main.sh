#!/bin/bash

main_disk=/dev/sda
efi_partition=/dev/sda1
swap_partition=/dev/sda2
main_partition=/dev/sda3

# Setup wifi
### TBD


timedatectl set-ntp true

pacman -Sy
pacman -S --noconfirm archlinux-keyring
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf


#setup disk partitions
umount -A --recursive /mnt    # just to make sure everything is unmounted
sgdisk -Z ${main_disk}        # "zap" the disk
sgdisk -a 2048 -o ${main_disk}


!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
todo=Add a bios boot partion for grub

sgdisk -n 1::+300M --typecode=1:ef00 --change-name=1:'EFIBOOT' ${main_disk}
sgdisk -n 2::+4G --typecode=2:8200 --change-name=2:'SWAP' ${main_disk}
sgdisk -n 3::-0 --typecode=3:8300 --change-name=3:'ROOT' ${main_disk}
partprobe ${main_disk}


# format partitions
mkfs.ext4 ${main_partition}
mkfs.fat -F 32 ${efi_partition}

# Setup swap partion
mkswap ${swap_partition}
swapon ${swap_partition}

#mount drier
mount $main_partition /mnt
mount --mkdir ${efi_partition} /mnt/boot



# Install my base packages
pacstrap /mnt --noconfirm --needed base linux linux-firmware base-devel gvim wpa_supplicant dhcpcd xorg-server xorg-xinit i3-wm i3status dmenu noto-fonts xorg-xrandr git chromium qutebrowser neofetch zathura zathura-pdf-poppler alsa-utils feh mpv jq openssh htop man-db xsel make 

# Create fstab file to mount drives
# The -U make it use UUIDs for the drives
genfstab -U /mnt >> /mnt/etc/fstab


# chroot to setup system configurations
arch-chroot /mnt 1_system.sh

# chroot to setup user configurations
#arch-chroot /mnt 2_user.sh


