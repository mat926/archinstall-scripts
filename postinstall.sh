#USAGE
#In a terminal run
#curl -fsSL https://raw.githubusercontent.com/mat926/archinstall-scripts/refs/heads/main/postinstall.sh | bash

# Remove some of the bloat installed with KDE
pacman -Rns --noconfirm ark kate konsole
echo "System setup finished successfully" >> ~/Desktop/postinstall_log.txt