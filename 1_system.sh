#!/bin/bash

main_disk=/dev/nvme0n1


# bootloader
pacman -Sy --noconfirm --needed grub
grub-install --efi-directory=/boot ${main_disk}
grub-mkconfig -o /boot/grub/grub.cfg

#turn on parallel pacman downloads
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf

# set root password
echo "Set root password:"
passwd

# Set locale
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

# set timezone
ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime

# set computer name
echo "NicDevMachine" > /etc/hostname

# create user account
useradd -m -g wheel nic
echo "Set password for nic account"
passwd nic

# add user to docker group
usermod -aG docker nic

# Allow wheel grup to do sudo commands
sed -i 's/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers

# SSH config
sed -i 's/^#Port 22/Port 4242/' /etc/ssh/sshd_config
sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
echo "" >> /etc/ssh/sshd_config
echo "AllowUsers nic" >> /etc/ssh/sshd_config

# Enable sshd 
systemctl enable sshd

# Enable dhcpcd 
systemctl enable dhcpcd

# Enable docker
systemctl enable docker

# Enable iwd which will do wifi stuff for iwctl 
systemctl enable iwd

