#USAGE
#In a terminal run
#curl -fsSL https://raw.githubusercontent.com/mat926/archinstall-scripts/refs/heads/main/postinstall.sh | bash
USERNAME=$(getent passwd 1000 | cut -d: -f1)
NOBODY="nobody"

# Remove some of the bloat installed with KDE
pacman -Rns --noconfirm ark kate discover #konsole




#######################################################
## Install AUR helpers
#######################################################
pacman -S --noconfirm --needed base-devel
cd /tmp
git clone https://aur.archlinux.org/paru.git paru-tmp
chown -R $USERNAME:$USERNAME paru-tmp
cd paru-tmp

# As root, add a temporary sudoers drop-in file to allow passwordless sudo for the user
echo "$USERNAME ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers.d/temp-sudoers

runuser -u $USERNAME -- makepkg -si --noconfirm

# Clean up after
cd /tmp
#rm -rf paru-tmp