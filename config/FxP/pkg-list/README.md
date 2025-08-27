# Package List Generator for Arch Linux

## One Command to Generate All Package Lists

Copy and run this single command to generate complete package lists for pacman, paru, and yay:

mkdir -p ~/.config/package-lists && pacman -Qqe | grep -v "$(pacman -Qqm)" > ~/.config/package-lists/pacman-pkgs.txt && pacman -Qqm > ~/.config/package-lists/aur-pkgs.txt




# How to reinstall evrything from that generated lists

## First nevigate to the pakage list directory the use these commands:

# Install native packages
sudo pacman -S --needed - < ~/.config/package-lists/pacman-pkgs.txt

# Install AUR packages (using paru or yay)
paru -S --needed - < ~/.config/package-lists/aur-pkgs.txt
