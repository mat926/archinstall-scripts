set -e

# #Create & add user
# useradd -m testuser
# echo "abc" | passwd -s testuser 

# #Make user a sudo user
# echo "testuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# #lougout root and login as the new user
# exit




#USAGE
#In a terminal run
#curl -fsSL https://raw.githubusercontent.com/mat926/archinstall-scripts/refs/heads/main/postinstall.sh | bash
# USERNAME=$(getent passwd 1000 | cut -d: -f1)
USERNAME=$(whoami)


# Remove some of the bloat installed with KDE
# pacman -Rns --noconfirm ark kate discover #konsole



#######################################################
## Install KDE Plasma apps
#######################################################
sudo pacman -Sy --needed --noconfirm \
    plasma-desktop \
    sddm \
    dolphin \
    spectacle \
    gwenview \
    okular \
    plasma-nm \
    plasma-pa \
    powerdevil \
    bluedevil \
    plasma-systemmonitor \
    kalk \
    kdeconnect \
    ksystemlog \
    kfind \
    krdp \
    kdegraphics-thumbnailers \
    ffmpegthumbs \
    print-manager \
    cups \
    system-config-printer \
    sddm-kcm \
    kde-gtk-config \
    kscreen \
    plasma-firewall \
    konsole \
    kwallet \
    breeze-gtk \
    kde-gtk-config \
    # kwalletmanager \
    ufw

# dolphin - file manager
# spectacle - screenshot tool
# gwenview - image viewer
# okular - pdf reader
# plasma-nm - network applet (very important!)
# plasma-pa - volume applet
# powerdevil - power management
# bluedevil - bluetooth (optional but useful)
# plasma-systemmonitor - system monitor applet
# kalk - calculator
# kdeconnect - connect to phone
# ksystemlog - system log viewer
# kfind - file search utility
# krdc - remote desktop client
# krdp - remote desktop server
# freerdp - rdp backend for krdc
# libvncserver - vnc backend for krdc
# kdegraphics-thumbnailers - thumbnails for images
# ffmpegthumbs - thumbnails for videos
# print-manager - printer management
# cups - printing system
# system-config-printer - printer configuration tool
# sddm-kcm - sddm configuration module for system setting
# kde-gtk-config - gtk themes support
# kscreen - multi monitor management
# plasma-firewall - firewall applet
# kwallet - password manager
# breeze-gtk - breeze theme for gtk apps
# kde-gtk-config - gtk theme configuration
# kwalletmanager - kwallet management app
# ufw - uncomplicated firewall backend

sudo systemctl enable sddm 

#Configure Plasma/Wayland on Nvidia
if lspci | grep -q -i nvidia; then
    echo "TODO : Configure Plasma/Wayland on Nvidia cards"
fi

#######################################################
## Install git
#######################################################

sudo pacman -S --noconfirm --needed git
read -p "Enter your Git username: " git_username < /dev/tty
read -p "Enter your Git email: " git_email < /dev/tty

git config --global user.name "$git_username"
git config --global user.email "$git_email"

# #######################################################
# ## Install AUR helpers
# #######################################################

sudo pacman -S --noconfirm --needed base-devel
cd /tmp
git clone https://aur.archlinux.org/paru.git paru-tmp
cd paru-tmp
makepkg -si --noconfirm

# # Clean up after
cd /tmp
rm -rf paru-tmp

paru -Sy

#KDEConnect should be working at this point 

# #######################################################
# ## Install GPU drivers
# #######################################################

if lspci | grep -q -i nvidia; then
    echo "TODO : install nvidia drivers"
    paru -S --needed --noconfirm nvidia-580xx-dkms nvidia-580xx-utils
fi



# #######################################################
# ## Install Brave
# #######################################################

paru -S --needed --noconfirm brave-bin

# #######################################################
# ## Install VLC
# #######################################################

sudo pacman -S --needed --noconfirm vlc

# #######################################################
# ## Install Steam
# #######################################################

#Enable multilib repository
sudo sed -i '/#\[multilib\]/,/Include/ s/^#//' /etc/pacman.conf

sudo pacman -Sy --needed --noconfirm steam


# #######################################################
# ## Install peazip
# #######################################################

paru -S --needed --noconfirm peazip-qt-bin

# #######################################################
# ## Install Remmina
# #######################################################

paru -S --needed --noconfirm remmina libvncserver freerdp

# #######################################################
# ## Install libreoffice
# #######################################################
#hunspell is for spell checking

sudo pacman -S --needed --noconfirm libreoffice-still hunspell

# #######################################################
# ## Install Discord
# #######################################################

#libappindicator is needed for discord to show tray icon
sudo pacman -S --needed --noconfirm discord libappindicator
#libunity is needed for discord to display badge counts on taskbar icon
paru -S --needed --noconfirm libunity

# #######################################################
# ## Install OBS
# #######################################################

sudo pacman -S --needed --noconfirm obs-studio

# #######################################################
# ## Install QEMU/virt-manager
# #######################################################


sudo pacman -S --needed libvirt qemu-full dnsmasq virt-manager dmidecode iptables-nft
systemctl enable libvirtd.service libvirtd.socket ufw.service

#Add user to the libvirt group
sudo gpasswd -a $USERNAME libvirt

#update nftables config to allow DNS/DHCP requests from VMs to host
# Insert INPUT rule after policy line
sudo sed -i '/chain input {/,/}/{/policy drop/a\
    iifname virbr0 udp dport {53, 67} accept comment "allow VM dhcp/dns requests to host"
}' /etc/nftables.conf

# Insert FORWARD rules after policy line
sudo sed -i '/chain forward {/,/}/{/policy drop/a\
    iifname virbr0 accept\
    oifname virbr0 accept
}' /etc/nftables.conf

#TODO automatically add the storage pools

# #######################################################
# ## Install VS Code
# #######################################################

paru -S --needed --noconfirm code code-marketplace

# #######################################################
# ## Install Zoom
# #######################################################

paru -S --needed --noconfirm zoom



# #######################################################
# ## Install Proton VPN
# #######################################################

sudo pacman -S --needed --noconfirm proton-vpn-gtk-app

# #######################################################
# ##  Finished
# #######################################################

echo "Post-installation script completed successfully!"

# 10 second countdown before reboot
for i in {10..1}; do
    echo "Rebooting in $i seconds..."
    sleep 1
done

reboot

#For fixing buzzing from speakers https://youtu.be/Kt0dkXWnaC4
#TODO automatically mount storage drive