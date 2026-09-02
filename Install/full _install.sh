#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "Starting installation for Hyprland setup..."

# 1. Update System
echo "Updating system..."
sudo pacman -Syu --noconfirm

# 2. Install Core Dependencies & Wayland Tools (including stable quickshell)
echo "Installing core packages..."
CORE_PKGS=(
    hyprland
    hypridle
    wl-clipboard
    cliphist
    git
    base-devel
    unzip
    tar
    neovim
    quickshell
    awww-daemon 
)
sudo pacman -S --needed --noconfirm "${CORE_PKGS[@]}"

# 3. Install AUR Packages
echo "Installing AUR packages..."
AUR_PKGS=(
    wl-clip-persist
)
yay -S --needed --noconfirm "${AUR_PKGS[@]}"

# 4. Setup Directories
echo "Creating necessary directories..."
mkdir -p ~/.config
mkdir -p ~/.local/share/icons
mkdir -p ~/.local/share/themes

# 5. Install Cursor Theme (Bibata-Modern-Ice)
echo "Installing Bibata-Modern-Ice cursor theme..."
if [ ! -d "$HOME/.local/share/icons/Bibata-Modern-Ice" ]; then
    wget -qO /tmp/Bibata.tar.xz "https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Modern-Ice.tar.xz"
    tar -xf /tmp/Bibata.tar.xz -C ~/.local/share/icons/
    rm /tmp/Bibata.tar.xz
    echo "Bibata Cursor installed."
else
    echo "Cursor already exists, skipping."
fi

# 6. Apply Cursor Theme
gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Ice'

# 7. Symlink/Copy Dotfiles
echo "Setting up dotfiles..."
DOTFILES_DIR="$HOME/dotfiles"

if [ -d "$DOTFILES_DIR" ]; then
    # ln -sf "$DOTFILES_DIR/nvim" ~/.config/nvim
    # ln -sf "$DOTFILES_DIR/hypr" ~/.config/hypr
    # ln -sf "$DOTFILES_DIR/quickshell" ~/.config/quickshell
    echo "Dotfiles linked (uncomment the lines in the script to activate)."
else
    echo "Dotfiles directory not found at $DOTFILES_DIR. Skipping."
fi

echo "Installation complete! Please restart your session to apply all changes."