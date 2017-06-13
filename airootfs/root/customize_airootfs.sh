#!/bin/bash

set -e -u

# Encoding
sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
sed -i 's/#\(fr_FR\.UTF-8\)/\1/' /etc/locale.gen
locale-gen

# localtime
ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime 

# configure root
usermod -s /usr/bin/zsh root
# chmod 700 /root

# Keyboard
loadkeys fr

# GIve guest adminrights
groupadd sudo
sed -i 's/# \(%sudo\tALL=(ALL) ALL\)/\1/' /etc/sudoers

# Create user
useradd -m -p "" -g users -G "sudo,adm,audio,floppy,log,network,rfkill,scanner,storage,optical,power,wheel" -s /usr/bin/zsh guest
cp -aT /etc/skel/ /home/guest
chown guest:users /home/guest -R

# Update user config through git if possible
bck_dir=$(pwd)
cd /home/guest
git remote update
git checkout master
git pull --rebase
git submodule update --init --recursive
cd $bck_dir

# semacs
HOME=/home/guest; emacs --eval '(kill-emacs)'

# SSHD
sed -i 's/#\(PermitRootLogin \).\+/\1no/' /etc/ssh/sshd_config
sed -i 's/#\(PasswordAuthentication \).\+/\1no/' /etc/ssh/sshd_config

# Pacman
sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist

# Journal
sed -i 's/#\(Storage=\)auto/\1volatile/' /etc/systemd/journald.conf

# Shutdown keys
sed -i 's/#\(HandleSuspendKey=\)suspend/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleHibernateKey=\)hibernate/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleLidSwitch=\)suspend/\1ignore/' /etc/systemd/logind.conf

# Additional packages
#   Calamares
git clone https://github.com/calamares/calamares /tmp/calamares
bck_dir=$(pwd)
cd /tmp/calamares
git submodule update --init --recursive
mkdir -p build; cd build
cmake ..; make; make install
cd $bck_dir

# #   Packer
# git clone https://aur.archlinux.org/packer.git /tmp/packer
# makepkg -is --needed --noconfirm /tmp/packer

# Add library paths
echo "/usr/local/lib\n/usr/local/lib64" > /etc/ld.so.d/libc.conf
ldconfig

# Services
systemctl enable pacman-init.service choose-mirror.service
systemctl enable freshclamd.service
systemctl enable clamd.service
systemctl set-default multi-user.target

