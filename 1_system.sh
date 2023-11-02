#!/bin/bash

main_disk=/dev/sda
main_partition=/dev/sda2


#turn on parallel pacman downloads
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf

# Install grub (boot loader)
pacman -S --noconfirm grub
grub-install $main_disk
grub-mkconfig -o /boot/grub/grub.cfg

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



# Allow wheel grup to do sudo commands
sed -i 's/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers

