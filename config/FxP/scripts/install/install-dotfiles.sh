#!/bin/bash

# This script automates creating symlinks for dotfiles from ~/.FxP to home directory

# Function to create symlink
create_symlink() {
    local src="$1"
    local dest="$2"

    # Check if destination exists; if so, back it up
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        echo "Backing up existing $dest to ${dest}.bak"
        mv "$dest" "${dest}.bak"
    fi

    # Create parent directory if needed
    mkdir -p "$(dirname "$dest")"

    # Create symlink
    ln -s "$src" "$dest"
    echo "Symlink created: $dest -> $src"
}

# Base directory where your dotfiles are stored
DOTFILES_DIR="$HOME/.FxP"

# List of dotfiles and config folders to symlink
create_symlink $DOTFILES_DIR/.zshrc $HOME/.zshrc
create_symlink $DOTFILES_DIR/.vimrc $HOME/.vimrc
create_symlink $DOTFILES_DIR/.bashrc $HOME/.bashrc
create_symlink $DOTFILES_DIR/.config/nvim $HOME/.config/nvim
create_symlink $DOTFILES_DIR/.config/hypr $HOME/.config/hypr
create_symlink $DOTFILES_DIR/.config/waybar $HOME/.config/waybar
create_symlink $DOTFILES_DIR/.config/rofi $HOME/.config/rofi
create_symlink $DOTFILES_DIR/.config/eww $HOME/.config/eww
create_symlink $DOTFILES_DIR/.config/kitty $HOME/.config/kitty

echo 'All dotfiles symlinked successfully.'

