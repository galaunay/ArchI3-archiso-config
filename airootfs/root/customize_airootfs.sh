#!/bin/bash

set -e -u

# Encoding
sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
sed -i 's/#\(fr_FR\.UTF-8\)/\1/' /etc/locale.gen
locale-gen

# localtime
ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime

# create root
usermod -s /usr/bin/zsh root
chmod 700 /root

# create user
#useradd -m -p "" -g users -G "adm,audio,floppy,log,network,rfkill,scanner,storage,optical,power,wheel" -s /usr/bin/zsh muahah
cp -aT /etc/skel/ /home/muahah
chown muahah:users /home/muahah -R

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

# Services
systemctl enable pacman-init.service choose-mirror.service
systemctl set-default multi-user.target

# # Packer
# git clone https://aur.archlinux.org/packer.git /tmp/packer
# makepkg -is /tmp/packer
