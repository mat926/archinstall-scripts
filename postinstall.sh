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
# NOBODY="nobody"

# Remove some of the bloat installed with KDE
# pacman -Rns --noconfirm ark kate discover #konsole

#######################################################
## Install KDE Plasma apps
#######################################################
sudo pacman -S --needed --noconfirm \
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
    krdc \
    freerdp \
    libvncserver \
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






echo "Post-installation script completed successfully!"

# 10 second countdown before reboot
for i in {10..1}; do
    echo "Rebooting in $i seconds..."
    sleep 1
done

reboot