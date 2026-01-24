set -e


#USAGE
#In a terminal run
#curl -fsSL https://raw.githubusercontent.com/mat926/archinstall-scripts/refs/heads/main/postinstall.sh | bash
# USERNAME=$(getent passwd 1000 | cut -d: -f1)
USERNAME=$(whoami)


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
# ## Install Clam AV
# #######################################################

sudo pacman -S --needed --noconfirm clamav

# Set up clamd.conf
sudo sed -i '/#ExtendedDetectionInfo yes/s/^#//' /etc/clamav/clamd.conf
sudo sed -i '/#MaxDirectoryRecursion 20/s/^#//' /etc/clamav/clamd.conf
sudo sed -i '/#DetectPUA yes/s/^#//' /etc/clamav/clamd.conf
sudo sed -i 's/^#ScanPE[[:space:]]\+no[[:space:]]*$/ScanPE yes/' /etc/clamav/clamd.conf
sudo sed -i 's/^#ScanOLE2[[:space:]]\+no[[:space:]]*$/ScanOLE2 yes/' /etc/clamav/clamd.conf
sudo sed -i 's/^#ScanPDF[[:space:]]\+no[[:space:]]*$/ScanPDF yes/' /etc/clamav/clamd.conf
sudo sed -i 's/^#ScanSWF[[:space:]]\+no[[:space:]]*$/ScanSWF yes/' /etc/clamav/clamd.conf
sudo sed -i 's/^#ScanXMLDOCS[[:space:]]\+no[[:space:]]*$/ScanXMLDOCS yes/' /etc/clamav/clamd.conf
sudo sed -i 's/^#ScanHWP3[[:space:]]\+no[[:space:]]*$/ScanHWP3 yes/' /etc/clamav/clamd.conf
sudo sed -i 's/^#ScanOneNote[[:space:]]\+no[[:space:]]*$/ScanOneNote yes/' /etc/clamav/clamd.conf
sudo sed -i 's/^#ScanMail[[:space:]]\+no[[:space:]]*$/ScanMail yes/' /etc/clamav/clamd.conf
sudo sed -i 's/^#ScanHTML[[:space:]]\+no[[:space:]]*$/ScanHTML yes/' /etc/clamav/clamd.conf
sudo sed -i 's/^#ScanArchive[[:space:]]\+no[[:space:]]*$/ScanArchive yes/' /etc/clamav/clamd.conf
sudo sed -i 's/^#ScanImage[[:space:]]\+no[[:space:]]*$/ScanImage yes/' /etc/clamav/clamd.conf
sudo sed -i 's/^#Bytecode[[:space:]]\+no[[:space:]]*$/Bytecode yes/' /etc/clamav/clamd.conf

sudo sed -i -E \
  -e 's/^[[:space:]]*#ExcludePath[[:space:]]+\^\/proc\//&# [disabled] /' \
  -e 's/^[[:space:]]*#ExcludePath[[:space:]]+\^\/sys\//&# [disabled] /' \
  /etc/clamav/clamd.conf
sudo sed -i -E \
  -e '/^[[:space:]]*#ExcludePath[[:space:]]+\^\/proc\//a\
ExcludePath ~/.local/share/Trash
' \
  /etc/clamav/clamd.conf

sudo sed -i '/#AlertBrokenExecutables yes/s/^#//' /etc/clamav/clamd.conf
sudo sed -i '/#AlertBrokenMedia yes/s/^#//' /etc/clamav/clamd.conf
sudo sed -i '/#AlertEncrypted yes/s/^#//' /etc/clamav/clamd.conf
sudo sed -i '/#AlertEncryptedArchive yes/s/^#//' /etc/clamav/clamd.conf
sudo sed -i '/#AlertEncryptedDoc yes/s/^#//' /etc/clamav/clamd.conf
sudo sed -i '/#AlertOLE2Macros yes/s/^#//' /etc/clamav/clamd.conf
sudo sed -i '/#AlertPartitionIntersection yes/s/^#//' /etc/clamav/clamd.conf

sudo sed -i 's/^#OnAccessMaxFileSize[[:space:]]\+10M[[:space:]]*$/OnAccessMaxFileSize 1G/' /etc/clamav/clamd.conf
sudo sed -i '/^#OnAccessExcludePath[[:space:]]/a\
OnAccessExcludePath ~/.*/\.local/share/Trash
' /etc/clamav/clamd.conf


#enable automatic database updates in freshclam.conf
sudo touch /var/log/clamav/freshclam.log
sudo chmod 600 /var/log/clamav/freshclam.log
sudo chown clamav /var/log/clamav/freshclam.log

#add sock file
sudo touch /run/clamav/clamd.ctl
sudo chown clamav:clamav /run/clamav/clamd.ctl

#enable real time protection OnAccess scanning
sudo sed -i '/#OnAccessExcludeUname clamav/s/^#//' /etc/clamav/clamd.conf
sudo sed -i '/^#OnAccessMountPath \/$/s/^#//' /etc/clamav/clamd.conf
sudo sed -i 's/^#OnAccessPrevention[[:space:]]\+yes[[:space:]]*$/OnAccessPrevention no/' /etc/clamav/clamd.conf
sudo sed -i '/#OnAccessExtraScanning yes/s/^#//' /etc/clamav/clamd.conf

#set up notification popups for alerts
sudo sed -i 's|^#VirusEvent[[:space:]]\+/opt/send_virus_alert_sms\.sh[[:space:]]*$|VirusEvent /etc/clamav/virus-event.bash|' /etc/clamav/clamd.conf
# allow the clamav user to run notify-send as any user with custom environment variables via sudo:
sudo touch /etc/sudoers.d/clamav
echo "clamav ALL = (ALL) NOPASSWD: SETENV: /usr/bin/notify-send" | sudo tee /etc/sudoers.d/clamav

sudo tee /etc/clamav/virus-event.bash > /dev/null << 'EOF'
#!/bin/bash
PATH=/usr/bin
ALERT="Signature detected by clamav: $CLAM_VIRUSEVENT_VIRUSNAME in $CLAM_VIRUSEVENT_FILENAME"

# Send an alert to all graphical users.
for ADDRESS in /run/user/*; do
    USERID=${ADDRESS#/run/user/}
    /usr/bin/sudo -u "#$USERID" DBUS_SESSION_BUS_ADDRESS="unix:path=$ADDRESS/bus" PATH=${PATH} \
        /usr/bin/notify-send -u critical -i dialog-warning "Virus found!" "$ALERT"
done
EOF

sudo chmod +x /etc/clamav/virus-event.bash

#  instruct clamonacc (which always runs as root) to use file descriptor passing
sudo mkdir -p /etc/systemd/system/clamav-clamonacc.service.d
sudo tee /etc/systemd/system/clamav-clamonacc.service.d/override.conf > /dev/null << 'EOF'
[Service]
ExecStart=
ExecStart=/usr/sbin/clamonacc -F --fdpass --log=/var/log/clamav/clamonacc.log
EOF

sudo systemctl enable clamav-clamonacc.service clamav-freshclam.service clamav-daemon.service

##Add more databases/signatures repositories
paru -S --needed --noconfirm python-fangfrisch
sudo -u clamav /usr/bin/fangfrisch --conf /etc/fangfrisch/fangfrisch.conf initdb
sudo systemctl enable fangfrisch.timer

#update virus definitions
sudo freshclam

##TESTING REALTIME SCANNING
# sudo pacman -S --needed --noconfirm wget
# cd ~/Downloads/
# wget https://secure.eicar.org/eicar.com.txt
# cat eicar.com.txt



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
# ## Install Timeshift - expirimental
# #######################################################

# paru -S --needed --noconfirm timeshift


# #######################################################
# ## Install Bleachbit
# #######################################################

 paru -S --needed --noconfirm bleachbit


# #######################################################
# ## Install Proton VPN
# #######################################################

sudo pacman -S --needed --noconfirm proton-vpn-gtk-app

# #######################################################
# ## Install Betterbird
# #######################################################

paru -S --needed --noconfirm betterbird-bin 
sudo pacman -S --needed --noconfirm libcanberra

# Libcanberra is needed for notification sounds

# #######################################################
# ## Install Insomnia
# #######################################################

paru -S --needed --noconfirm insomnia-bin


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

# paru -S --needed --noconfirm arch-update

# #enable the system tray
# arch-update --tray --enable

# #enable the systemd timer to perform automatic and periodic checks for available updates
# systemctl --user enable arch-update.timer


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