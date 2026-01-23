set -e


#USAGE
#In a terminal run
#curl -fsSL https://raw.githubusercontent.com/mat926/archinstall-scripts/refs/heads/main/postinstall.sh | bash
# USERNAME=$(getent passwd 1000 | cut -d: -f1)
USERNAME=$(whoami)


# Remove some of the bloat installed with KDE
# pacman -Rns --noconfirm ark kate discover #konsole

#######################################################
## Questions
#######################################################

read -p "Enter your Git username: " GIT_USERNAME < /dev/tty
read -p "Enter your Git email: " GIT_EMAIL < /dev/tty

read -p "Are you using any Razer pheripherals? (y/N) " REPLY < /dev/tty

# Default to "no" if user just presses Enter
if [[ $REPLY =~ ^[Yy]$ ]]; then
    HAS_RAZER=true
else
    HAS_RAZER=false
fi

read -p "Are you mounting an additional HDD drive formatted in NTFS? (y/N) " REPLY < /dev/tty

# Default to "no" if user just presses Enter
if [[ $REPLY =~ ^[Yy]$ ]]; then
    HAS_NTFS_HDD=true
else
    HAS_NTFS_HDD=false
fi

read -p "Are you dual booting with Windows? (Y/b) " REPLY < /dev/tty

# Default to "no" if user just presses Enter
if [[ $REPLY =~ ^[Nn]$ ]]; then
    IS_WIN_DUALBOOT=false
else
    IS_WIN_DUALBOOT=true
fi

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
    kcron \
    kinfocenter \
    partitionmanager \
    system-config-printer \
    sddm-kcm \
    kde-gtk-config \
    kscreen \
    plasma-firewall \
    konsole \
    kwallet \
    breeze-gtk \
    kde-gtk-config \
    kwalletmanager \
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
# kcron - cron job manager
# kinfocenter - system information
# partitionmanager - disk partitioning tool
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
# kwalletmanager - kwallet management app #TODO remove?
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

git config --global user.name "$GIT_USERNAME"
git config --global user.email "$GIT_EMAIL"

# #######################################################
# ## Install AUR helpers
# #######################################################

sudo pacman -S --noconfirm --needed base-devel
cd /tmp
#check if the directory exists first
if [ ! -d "paru-tmp" ]; then
    git clone https://aur.archlinux.org/paru.git paru-tmp
fi
cd paru-tmp
makepkg -si --noconfirm

# # Clean up after #TODO uncomment later
# cd /tmp
# rm -rf paru-tmp

paru -Sy

#KDEConnect should be working at this point 

# #######################################################
# ## Install GPU drivers
# #######################################################

if lspci | grep -i nvidia | grep -i "gtx 1080"; then
    echo "Detected GTX 1080 - installing legacy 580.xx drivers (required since late 2025)"
    paru -S --needed --noconfirm nvidia-580xx-dkms nvidia-580xx-utils
fi



# #######################################################
# ## Install Brave
# #######################################################

paru -S --needed --noconfirm brave-bin

# #######################################################
# ## Install VLC
# #######################################################

sudo pacman -S --needed --noconfirm vlc vlc-plugins-all

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
#TODO disable update checks https://wiki.archlinux.org/title/Discord#Discord_asks_for_an_update_not_yet_available_in_the_repository


# #######################################################
# ## Install OBS
# #######################################################

sudo pacman -S --needed --noconfirm obs-studio

# #######################################################
# ## Install Razer polychromatic
# #######################################################

#TODO test
if [ "$HAS_RAZER" = true ] ; then
    sudo pacman -S --needed --noconfirm linux-headers linux-lts-headers
    paru -S --needed --noconfirm polychromatic 
    #Add user to the openrazer group to allow access to the Razer devices
    sudo gpasswd -a $USERNAME openrazer
fi

# #######################################################
# ## Install and setup storage drive NTFS mount
# #######################################################

if [ "$HAS_NTFS_HDD" = true ] ; then
    sudo pacman -S --needed --noconfirm gsmartcontrol ntfs-3g
    sudo systemctl enable smartd
    #Add user to the openrazer group to allow access to the Razer devices
    sudo gpasswd -a $USERNAME openrazer
fi


# #######################################################
# ## Install Dolphin plugins
# #######################################################

sudo pacman -S --needed --noconfirm libheif libappimage dolphin-plugins
# libheif : Shows thumbnails for HEIC images
# libappimage : embedded *.AppImage icons
# dolphin-plugins: adds Git, Bazaar, Mercurial and Dropbox support and some mounting actions


# audiocd-kio: adds audio CD support
# baloo: extends tagging support (see #File tagging)
# kio-admin: allows managing files as administrator
# kio-gdrive: adds Google Drive support (see #KIO slaves)
# kompare: adds the Compare files dialog (Alternatively, select two files: {right click} > Open With > {your diff tool}.)
# konsole: integrated terminal panel


# #######################################################
# ## Install QEMU/virt-manager
# #######################################################

sudo pacman -S --needed libvirt qemu-full dnsmasq virt-manager dmidecode iptables-nft  < /dev/tty
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
# ## Install Betterbird
# #######################################################

paru -S --needed --noconfirm betterbird-bin


# #######################################################
# ## Install Ventoy
# #######################################################

#Commented out for now https://github.com/ventoy/Ventoy/issues/3224
#paru -S --needed --noconfirm ventoy-bin

# #######################################################
# ## Install Balena Etcher (replacement for Ventoy) - Optional
# #######################################################

#Commented out for now https://github.com/ventoy/Ventoy/issues/3224
# paru -S --needed --noconfirm balena-etcher

# #######################################################
# ## Enable services
# #######################################################

sudo systemctl enable cronie.service 


# #######################################################
# ## Install arch-update 
# #######################################################

paru -S --needed --noconfirm arch-update

#enable the system tray
arch-update --tray --enable

#enable the systemd timer to perform automatic and periodic checks for available updates
systemctl --user enable arch-update.timer


# #######################################################
# ## Install CLI tools
# #######################################################

paru -S --needed --noconfirm vim nano htop wget jq openssh arch-audit man-db

#arch-audit : security audit tool for installed packages
#man-db : tools for reading man pages 


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