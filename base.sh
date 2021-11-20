#!/bin/bash
printf "\e[1;36mWelcome to AutoInstaller Script.\n\e[0m"
sleep 2

# create swap-file
printf "\e[1;32mCreate Swap-File.\n\e[0m"
sleep 2
dd if=/dev/zero of=/swapfile bs=1M count=2048
mkswap /swapfile
chmod 600 /swapfile
swapon /swapfile
echo -e "/swapfile\tnone\tswap\tdefaults\t0\t\t0" >> /etc/fstab

# set time-zone
printf "\e[1;32mSet TimeZone.\n\e[0m"
sleep 2
ln -sf /usr/share/zoneinfo/Asia/Riyadh /etc/localtime

# set hardware clock
printf "\e[1;32mConfigure Clock.\n\e[0m"
hwclock --systohc

# set locale languages
printf "\e[1;32mConfigure Locales.\n\e[0m"
sleep 2
sed -i 's/^\#ar\_SA\.UTF\-8/ar\_SA\.UTF\-8/; 62s/^\#en\_US\.UTF\-8/en\_US\.UTF\-8/;' /etc/locale.gen  
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "KEYMAP=us" >> /etc/vconsole.conf

# set PC name
printf "\e[1;32mSet PC name.\n\e[0m"
sleep 2
echo "arch" >> /etc/hostname

# set localhost
printf "\e[1;32mConfigure localhost.\n\e[0m"
sleep 2
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1	localhost" >> /etc/hosts
echo "127.0.0.1 arch.localdomain arch" >> /etc/hosts

# set root password to be 123
printf "\e[1;32mSet root password.\n\e[0m"
sleep 2
echo root:123 | chpasswd

# select all pakages to install 
printf "\e[1;32mInstall all needed packages.\n\e[0m"
sleep 2
# enable parallel downloads
sed -i 's/^\#ParallelDownloads\ \=\ 5/ParallelDownloads\ \=\ 10/' /etc/pacman.conf
#pacman -S --noconfirm grub efibootmgr networkmanager network-manager-applet dialog wpa_supplicant mtools dosfstools reflector base-devel linux-lts-headers avahi xdg-user-dirs xdg-utils gvfs gvfs-smb nfs-utils inetutils dnsutils bluez bluez-utils cups hplip alsa-utils pulseaudio xorg pavucontrol bash-completion openssh rsync openssh acpi acpi_call tlp virt-manager qemu qemu-arch-extra edk2-ovmf openbsd-netcat vde2 dnsmasq bridge-utils ipset firewalld flatpak sof-firmware nss-mdns acpid os-prober ntfs-3g terminus-font
pacman -S --noconfirm grub efibootmgr networkmanager wpa_supplicant mtools dosfstools reflector base-devel linux-lts-headers avahi gvfs gvfs-smb nfs-utils inetutils dnsutils bluez bluez-utils cups hplip alsa-utils pulseaudio bash-completion openssh rsync openssh acpi acpi_call tlp virt-manager qemu qemu-arch-extra edk2-ovmf openbsd-netcat dnsmasq bridge-utils ipset firewalld flatpak sof-firmware nss-mdns acpid os-prober ntfs-3g terminus-font curl wget most htop cmatrix gcc gdb lsd ranger vi

# select video-graphic driver
printf "\e[1;32mInstall VGA driver.\n\e[0m"
sleep 2
# pacman -S --noconfirm xf86-video-amdgpu
# pacman -S --noconfirm nvidia nvidia-utils nvidia-settings
# pacman -S --noconfirm xf86-video-intel
# pacman -S --noconfirm xf86-video-nouveau
pacman -S --noconfirm xf86-video-vmware

# install grub
printf "\e[1;32mInstall GRUB Bootloader for UEFI.\n\e[0m"
sleep 2
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Arch_Linux
grub-mkconfig -o /boot/grub/grub.cfg

# enable services
printf "\e[1;32mEnable Services\n\e[0m"
sleep 2
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable cups.service
systemctl enable sshd
systemctl enable avahi-daemon
systemctl enable tlp
systemctl enable reflector.timer
systemctl enable fstrim.timer
systemctl enable libvirtd
systemctl enable firewalld
systemctl enable acpid

# create new user
printf "\e[1;32mCreate new user\n\e[0m"
sleep 1
printf "\e[1;31m  Enter your username: \e[1;33m"
#user="user"
read user
printf "\e[0m"
printf "\e[1;31m  Enter your password: \e[1;33m"
read pwd
printf "\e[0m"
useradd -m $user
echo $user:$pwd | chpasswd
usermod -aG libvirt,sudo $user

# make user sudoer
printf "\e[1;32mMake user ( \e[1;33m$user\e[1;32m ) sudoer.\n\e[0m"
#echo "$user ALL=(ALL) ALL" >> /etc/sudoers.d/$user
sed -i 's/\#\ \%sudo/\ \%sudo/' /etc/sudoers

# create user home folders
printf "\e[1;32mCreate ( \e[1;33m$user\e[1;32m ) home folder.\n\e[0m"
userHOME=/home/$user
mkdir -p $userHOME/Desktop $userHOME/Documents $userHOME/Downloads $userHOME/trash
printf "\e[1;35mUser ( \e[1;33m$user\e[1;35m ) Created.\n\e[0m"
sleep 1

# install vim configs
printf "\e[1;32mInstall Vim Config\n\e[0m"
git clone https://github.com/tag2000sa/vim_config.git /.vim_config
pushd /.vim_config
./install_vim_config.sh
printf "\e[1;36m - installed for root\n\e[0m"
sudo -u $user ./install_vim_config.sh
popd
printf "\e[1;36m - installed for \e[1;33m$user\n\e[0m"

# set default font size
if [[ `grep "FONT" /etc/vconsole.conf` == FONT* ]];then sed -i '/FONT\=/d' /etc/vconsole.conf; fi
echo "FONT=\"ter-128n\"" >> /etc/vconsole.conf

printf "\e[1;31m-------------------- Done!--------------------\n\e[1;32mType:\n\texit\n\tumount -R /mnt\n\treboot\n\e[0m"
