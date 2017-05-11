#!/bin/bash

set -e -u

# Encoding
sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
sed -i 's/#\(fr_FR\.UTF-8\)/\1/' /etc/locale.gen
locale-gen

# localtime
ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime 
# # configure root
# usermod -s /usr/bin/zsh root
# chmod 700 /root

# GIve guest adminrights
groupadd sudo
sed -i 's/# \(%sudo\tALL=(ALL) ALL\)/\1/' /etc/sudoers
# create user
useradd -m -p "" -g users -G "sudo,adm,audio,floppy,log,network,rfkill,scanner,storage,optical,power,wheel" -s /usr/bin/zsh guest
cp -aT /etc/skel/ /home/guest
chown guest:users /home/guest -R
# update config through git if possiblr
bck_dir=$(pwd)
cd /home/guest
git remote update
git checkout master
git pull --rebase
git submodule update --init --recursive
cd $bck_dir

# SSHD
sed -i 's/#\(PermitRootLogin \).\+/\1no/' /etc/ssh/sshd_config
sed -i 's/#\(PasswordAuthentication \).\+/\1no/' /etc/ssh/sshd_config

# Pacman
sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist

# Journal
sed -i 's/#\(Storage=\)auto/\1volatile/' /etc/systemd/journald.conf

# shutdown keys
sed -i 's/#\(HandleSuspendKey=\)suspend/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleHibernateKey=\)hibernate/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleLidSwitch=\)suspend/\1ignore/' /etc/systemd/logind.conf

# Additional packages
#   Calamares
bck_dir=$(pwd)
cp -r /root/additional_packages/calamares /tmp/calamares
cd /tmp/calamares
git submodule update --init --recursive
git clean -f -d
rm -fr build
mkdir -p build; cd build
cmake ..; make
rm -rf /root/additional_packages/calamares
cd $bck_dir

# Services
systemctl enable pacman-init.service choose-mirror.service
systemctl set-default multi-user.target

# # Packer
# git clone https://aur.archlinux.org/packer.git /tmp/packer
# makepkg -is /tmp/packer
