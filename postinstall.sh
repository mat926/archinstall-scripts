#USAGE
#In a terminal run
#curl -fsSL https://raw.githubusercontent.com/mat926/archinstall-scripts/refs/heads/main/postinstall.sh | bash
USERNAME=$(getent passwd 1000 | cut -d: -f1)

# Remove some of the bloat installed with KDE
pacman -Rns --noconfirm ark kate #konsole


#######################################################
## Install AUR helpers
#######################################################
pacman -S --noconfirm --needed base-devel
cd /tmp
git clone https://aur.archlinux.org/paru.git paru-tmp
chown -R $USERNAME:$USERNAME paru-tmp
cd paru-tmp
#runuser -u $USERNAME -- makepkg -si --noconfirm

# Clean up after
cd /tmp
#rm -rf paru-tmp