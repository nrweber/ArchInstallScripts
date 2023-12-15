#!/bin/bash

main_disk=/dev/nvme0n1
efi_partition=/dev/nvme0n1p2
swap_partition=/dev/nvme0n1p3
main_partition=/dev/nvme0n1p4

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


sgdisk -n 1::+1M --typecode=1:ef02 --change-name=1:'BIOSBOOT' ${main_disk}
sgdisk -n 2::+300M --typecode=2:ef00 --change-name=2:'EFIBOOT' ${main_disk}
sgdisk -n 3::+4G --typecode=3:8200 --change-name=3:'SWAP' ${main_disk}
sgdisk -n 4::-0 --typecode=4:8300 --change-name=4:'ROOT' ${main_disk}
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


# make sure reflector is installed and run it to update mirror list
pacman -Sy --noconfirm --needed reflector
reflector --verbose --country 'United States' -l 10 --sort rate --save /etc/pacman.d/mirrorlist


# Install my base packages
pacstrap /mnt --noconfirm --needed  \
    base \
    linux  \
    linux-firmware  \
    base-devel  \
    gvim  \
    wpa_supplicant  \
    dhcpcd  \
    xorg-server  \
    xorg-xinit  \
    i3-wm  \
    i3status  \
    dmenu  \
    noto-fonts  \
    xorg-xrandr  \
    git  \
    chromium  \
    qutebrowser  \
    neofetch  \
    zathura  \
    zathura-pdf-poppler  \
    alsa-utils  \
    feh  \
    mpv  \
    jq  \
    openssh  \
    htop  \
    man-db  \
    xsel  \
    make \
    efibootmgr \
    docker \
    docker-compose \
    rust

# Create fstab file to mount drives
# The -U make it use UUIDs for the drives
genfstab -U /mnt >> /mnt/etc/fstab


# Copy scripts to mount folder
temp_folder=/nic_installscripts/
mkdir /mnt/${temp_folder} 
cp 1_system.sh /mnt/${temp_folder}
cp 2_user.sh /mnt/${temp_folder}

# chroot to setup system configurations
arch-chroot /mnt /${temp_folder}/1_system.sh

# chroot to setup user configurations
arch-chroot /mnt /usr/bin/runuser -u nic -- /${temp_folder}/2_user.sh

#remove temp scripts
rm -fr /mnt/${temp_folder}
