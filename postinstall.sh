#USAGE
#In a terminal run
#curl -fsSL https://raw.githubusercontent.com/mat926/archinstall-scripts/refs/heads/main/postinstall.sh | bash

# Remove some of the bloat installed with KDE
pacman -Rns --noconfirm ark kate #konsole


#######################################################
## Install AUR helpers
#######################################################
cd /tmp
pacman -S --noconfirm--needed base-devel
git clone https://aur.archlinux.org/paru.git paru-tmp
chown -R testuser:testuser paru-tmp
cd paru-tmp
runuser -u testuser -- makepkg -si --noconfirm

# Clean up after
cd /tmp
rm -rf paru-tmp